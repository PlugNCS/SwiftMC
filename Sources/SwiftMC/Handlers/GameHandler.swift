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

class GameHandler: PacketHandler {
    
    var channel: ChannelWrapper?
    
    func connected(channel: ChannelWrapper) {
        // Save channel
        self.channel = channel
        
        // Fire PlayerConnectEvent
        let event = PlayerConnectEvent(player: channel, world: channel.server.worlds.first)
        channel.server.fireListeners(for: event)
        
        // Login to the selected world
        if let world = event.world {
            channel.goTo(world: world)
        } else {
            disconnect(reason: "No world found on this server!")
            return
        }
    }
    
    func disconnected(channel: ChannelWrapper) {
        // Remove channel
        self.channel = nil
        
        // Foward to remote world
        if let world = channel.world {
            world.disconnect(client: channel)
        }
    }
    
    func shouldHandle(packet: Packet) -> Bool {
        return !(channel?.closing ?? true)
    }
    
    func handle(packet: Packet) {
        // Check packet type
        if let pluginMessage = packet as? PluginMessage {
            self.handle(pluginMessage: pluginMessage)
        }
        if let chat = packet as? Chat {
            if self.handle(chat: chat) {
                return
            }
        }
        
        // Foward packets to world
        if let channel = channel, let world = channel.world {
            world.handle(packet: packet, for: channel)
        }
    }
    
    func handle(pluginMessage: PluginMessage) {
        // Get channel
        if let channel = channel {
            // Check for a register
            if (pluginMessage.tag == "minecraft:register" || pluginMessage.tag == "REGISTER"), let string = String(bytes: Data(pluginMessage.data), encoding: .utf8) {
                // Iterate registered channels
                for pluginChannel in string.split(separator: "\0") {
                    // Save the registered channels
                    channel.pluginMessageChannels.append(String(pluginChannel))
                    
                    // If the channel is a SwiftMC channel
                    if pluginChannel.starts(with: "swiftmc:") {
                        // Log it
                        channel.server.log(ChatMessage(text: "\(channel.getName()) registered plugin message channel \(pluginChannel)"))
                        
                        // Check for SwiftMC:Premium channel
                        if pluginChannel == "swiftmc:premium" {
                            // Send message to ask for the access token
                            channel.send(packet: PluginMessage(tag: "swiftmc:premium", data: [0x01]))
                        }
                    }
                }
            }
            
            // Check for a SwiftMC:Premium message
            var buffer = ByteBuffer(ByteBufferView(pluginMessage.data))
            if pluginMessage.tag == "swiftmc:premium" && buffer.readableBytes >= 2 && buffer.readBytes(length: 1)?.first == 0x02 {
                // Read the token
                channel.accessToken = buffer.readVarString()
            }
        }
    }
    
    func handle(chat: Chat) -> Bool {
        if let channel = channel {
            // Check for a command
            if chat.message.starts(with: "/") {
                // Handle the command
                let follow = channel.world as? RemoteWorld != nil
                if channel.server.dispatchCommand(sender: channel, command: String(chat.message.suffix(chat.message.count - 1)), showError: !follow) {
                    return true
                }
                return !follow
            }
        }
        return false
    }
    
    func disconnect(reason: String) {
        channel?.kick(reason: reason)
    }
    
}
