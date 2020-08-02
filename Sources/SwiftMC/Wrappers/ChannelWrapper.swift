/*
*  Copyright (C) 2020 Groupe MINASTE
*
* This program is free software; you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation; either version 2 of the License, or
* (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License along
* with this program; if not, write to the Free Software Foundation, Inc.,
* 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
*
*/

import Foundation
import NIO

public class ChannelWrapper: Player {
    
    // Channel related
    internal var id: Int32
    internal var server: SwiftMC
    internal var channel: Channel
    internal var handler: ChannelHandler?
    internal var threshold: Int32 = -1
    internal var closed: Bool = false
    internal var closing: Bool = false
    internal var promise: EventLoopPromise<Void>?
    
    // Other channels
    internal var remoteChannel: ChannelWrapper?
    internal var pingChannel: ChannelWrapper?
    
    // Encoding/Decoding
    internal var decoder: MinecraftDecoder
    internal var encoder: MinecraftEncoder
    internal var protocolVersion: Int32
    internal var prot: Prot
    
    // Encryption
    internal var encryptionRequest: EncryptionRequest?
    internal var sharedKey: [UInt8]?
    
    // Player related
    internal var receivedLogin: Bool = false
    internal var onlineMode: Bool = false
    internal var lastDimmension: Int32?
    internal var properties: [[String: Any]]?
    internal var name: String?
    internal var uuid: String?
    internal var accessToken: String?
    
    // World related
    internal var world: WorldProtocol?
    internal var location: Location?
    internal var gamemode: GameMode?
    internal var prevCentralX: Int32?
    internal var prevCentralZ: Int32?
    internal var knownChunks = [(Int32, Int32)]()
    
    // Plugin message channels
    internal var pluginMessageChannels = [String]()
    
    internal init(id: Int32, server: SwiftMC, channel: Channel, decoder: MinecraftDecoder, encoder: MinecraftEncoder, prot: Prot, protocolVersion: Int32) {
        self.id = id
        self.server = server
        self.channel = channel
        self.decoder = decoder
        self.encoder = encoder
        self.prot = prot
        self.protocolVersion = protocolVersion
        self.decoder.channel = self
        self.encoder.channel = self
    }
    
    internal func setHandler(handler: PacketHandler) {
        self.handler?.handler?.disconnected(channel: self)
        self.handler?.handler = handler
        self.handler?.handler?.connected(channel: self)
    }
    
    internal func send(packet: Packet, newProtocol: Prot? = nil, threshold: Int32? = nil, sharedKey: [UInt8]? = nil) {
        if !closed {
            // Check packet type
            if packet as? Login != nil {
                if receivedLogin {
                    // Don't send again
                    return
                }
                receivedLogin = true
            }
            
            // Check for debug
            if server.configuration.debug {
                if handler is RemoteWorld.RemoteWorldHandler {
                    server.log("SERVER -> WORLD: \(packet.toString())")
                } else {
                    server.log("SERVER -> CLIENT: \(packet.toString())")
                }
            }
            
            // Send packet
            let newPromise = channel.eventLoop.makePromise(of: Void.self)
            let send = {
                // Packet content
                self.channel.writeAndFlush(packet, promise: newPromise)
                
                // Update threshold
                if let threshold = threshold {
                    self.threshold = threshold
                }
                
                // Protocol switching
                if let newProtocol = newProtocol {
                    self.prot = newProtocol
                }
                
                // Shared key registration
                if let sharedKey = sharedKey {
                    self.sharedKey = sharedKey
                    self.decoder.iv = sharedKey
                    self.encoder.iv = sharedKey
                }
            }
            if let promise = promise {
                // After current waiting list
                promise.futureResult.whenComplete { _ in
                    send()
                }
            } else {
                // Now
                send()
            }
            self.promise = newPromise
        }
    }
    
    internal func close(packet: Packet? = nil) {
        if !closed {
            // Mark as closed
            closing = true
            closed = true
            handler?.handler?.disconnected(channel: self)
            
            // Remove from server clients
            server.clients.removeAll(where: { client in
                id == client.id
            })
            
            // Fire PlayerDisconnectEvent
            let event = PlayerDisconnectEvent(player: self)
            server.fireListeners(for: event)
            
            // Send close packet if there is one
            if let packet = packet {
                let _ = channel.writeAndFlush(packet).and(channel.close())
            } else {
                channel.flush()
                let _ = channel.close()
            }
        }
    }
    
    internal func unloadCurrentWorld() {
        // Disconnect
        self.world?.disconnect(client: self)
        
        // Remove channel for remote worlds
        self.remoteChannel = nil
        
        // Reset the tab list message
        self.setTabListMessage(header: ChatMessage(text: ""), footer: ChatMessage(text: ""))
        
        // Clear chunk related data
        self.location = nil
        self.prevCentralX = nil
        self.prevCentralZ = nil
        self.knownChunks = []
    }
    
    internal func sendCurrentChunks() {
        // Check if world is a local world
        if let world = world as? LocalWorld {
            // Get base data
            let centralX = getLocation().blockX >> 4
            let centralZ = getLocation().blockZ >> 4
            let radius: Int32 = min(server.configuration.viewDistance, 16) // TODO: Replace 16 by client configuration
            
            // Chunks to load or unload
            var newChunks = [(Int32, Int32)]()
            var oldChunks = [(Int32, Int32)]()
            
            // Check if chunks were sent once
            if let prevCentralX = prevCentralX, let prevCentralZ = prevCentralZ {
                // Check if an update is required
                if abs(centralX - prevCentralX) > radius || abs(centralX - prevCentralX) > radius {
                    // Reset known chunks
                    knownChunks = []
                    
                    // Iterate all chunks
                    for x in centralX - radius ..< centralX + radius {
                        for z in centralZ - radius ..< centralZ + radius {
                            newChunks.append((x, z))
                        }
                    }
                } else if centralX != prevCentralX || centralZ != prevCentralZ {
                    // Copy known chunks
                    oldChunks.append(contentsOf: knownChunks)
                    
                    // Iterate all chunks
                    for x in centralX - radius ..< centralX + radius {
                        for z in centralZ - radius ..< centralZ + radius {
                            // Check if the chunk should be loaded or unloaded
                            if knownChunks.contains(where: { $0.0 == x && $0.1 == z }) {
                                oldChunks.removeAll(where: { $0.0 == x && $0.1 == z })
                            } else {
                                newChunks.append((x, z))
                            }
                        }
                    }
                } else {
                    // Nothing to load
                    return
                }
            } else {
                // Iterate all chunks
                for x in centralX - radius ..< centralX + radius {
                    for z in centralZ - radius ..< centralZ + radius {
                        newChunks.append((x, z))
                    }
                }
            }
            
            // Update previous centers
            self.prevCentralX = centralX
            self.prevCentralZ = centralZ
            
            // Sort chunks by distance
            newChunks.sort { c1, c2 -> Bool in
                var dx = 16 * c1.0 + 8 - getLocation().blockX
                var dz = 16 * c1.1 + 8 - getLocation().blockZ
                let d1 = dx * dx + dz * dz
                dx = 16 * c2.0 + 8 - getLocation().blockX
                dz = 16 * c2.1 + 8 - getLocation().blockZ
                let d2 = dx * dx + dz * dz
                return d1 <= d2
            }
            
            // Load new chunks
            
            // Check if skylight should be sent (disabled for nether or end)
            let skylight = true // TODO: Change when implementing dimensions
            
            // Send new chunks
            newChunks.forEach { loc in
                knownChunks.append(loc)
                world.loadChunk(x: loc.0, z: loc.1) { chunk in
                    if let chunk = chunk {
                        self.send(packet: chunk.toMapChunkPacket(protocolVersion: self.protocolVersion, skylight: skylight))
                    }
                }
            }
            
            // Unload old chunks
            oldChunks.forEach { loc in
                // TODO: Send chunk unload packet
                knownChunks.removeAll(where: { $0.0 == loc.0 && $0.1 == loc.1 })
            }
        }
    }
    
    // Adapters for outside
    
    public func getName() -> String {
        return name ?? "Player"
    }
    
    public func getUUID() -> String {
        return uuid ?? "NULL"
    }
    
    public func getID() -> Int32 {
        return id
    }
    
    public func getLocation() -> Location {
        if let location = location {
            return location
        }
        fatalError("This player has no location")
    }
    
    public func getGameMode() -> GameMode {
        if let gamemode = gamemode {
            return gamemode
        }
        fatalError("This player has no gamemode")
    }
    
    public func setGameMode(to gamemode: GameMode) {
        // Set the gamemode
        self.gamemode = gamemode
        
        // Send update packets
        self.send(packet: GameState(reason: GameState.change_gamemode, value: Float32(gamemode)))
        (self.world as? LocalWorld)?.broadcast(packet: PlayerInfo(action: .update_gamemode, items: [PlayerInfo.Item(uuid: getUUID(), username: getName(), properties: [], gamemode: gamemode, ping: nil, displayname: nil)]))
    }
    
    public func sendMessage(message: ChatMessage) {
        self.send(packet: Chat(message: message))
    }
    
    public func goTo(world: WorldProtocol) {
        self.unloadCurrentWorld()
        self.world = world
        self.world?.connect(client: self)
    }
    
    public func kick(reason: String) {
        if let json = ChatMessage(text: reason).toJSON() {
            close(packet: Kick(message: json))
        } else {
            close()
        }
    }
    
    public func isOnlineMode() -> Bool {
        return onlineMode
    }
    
    public func hasSwiftMCPremium() -> Bool {
        return onlineMode && pluginMessageChannels.contains("swiftmc:premium") && accessToken != nil
    }
    
    public func setTabListMessage(header: ChatMessage, footer: ChatMessage) {
        send(packet: PlayerListHeaderFooter(header: header.toJSON() ?? "{}", footer: footer.toJSON() ?? "{}"))
    }
    
}
