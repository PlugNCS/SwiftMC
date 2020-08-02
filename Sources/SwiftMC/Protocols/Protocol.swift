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

class Prot: Equatable {
    
    // Register protocols
    static let HANDSHAKE = Prot(name: "HANDSHAKE") { to_server, _ in
        to_server.registerPacket(packetClass: Handshake.self, mappings: [
            ProtocolMapping(protocolVersion: ProtocolConstants.minecraft_1_8, packetID: 0x00)
        ])
    }
    static let GAME = Prot(name: "GAME") { to_server, to_client in
        to_client.registerPacket(packetClass: KeepAlive.self, mappings: [
            ProtocolMapping(protocolVersion: ProtocolConstants.minecraft_1_8, packetID: 0x00),
            ProtocolMapping(protocolVersion: ProtocolConstants.minecraft_1_9, packetID: 0x1F),
            ProtocolMapping(protocolVersion: ProtocolConstants.minecraft_1_13, packetID: 0x21),
            ProtocolMapping(protocolVersion: ProtocolConstants.minecraft_1_14, packetID: 0x20),
            ProtocolMapping(protocolVersion: ProtocolConstants.minecraft_1_15, packetID: 0x21)
        ])
        to_client.registerPacket(packetClass: Login.self, mappings: [
            ProtocolMapping(protocolVersion: ProtocolConstants.minecraft_1_8, packetID: 0x01),
            ProtocolMapping(protocolVersion: ProtocolConstants.minecraft_1_9, packetID: 0x23),
            ProtocolMapping(protocolVersion: ProtocolConstants.minecraft_1_13, packetID: 0x25),
            ProtocolMapping(protocolVersion: ProtocolConstants.minecraft_1_15, packetID: 0x26)
        ])
        to_client.registerPacket(packetClass: Chat.self, mappings: [
            ProtocolMapping(protocolVersion: ProtocolConstants.minecraft_1_8, packetID: 0x02),
            ProtocolMapping(protocolVersion: ProtocolConstants.minecraft_1_9, packetID: 0x0F),
            ProtocolMapping(protocolVersion: ProtocolConstants.minecraft_1_13, packetID: 0x0E),
            ProtocolMapping(protocolVersion: ProtocolConstants.minecraft_1_15, packetID: 0x0F)
        ])
        to_client.registerPacket(packetClass: Respawn.self, mappings: [
            ProtocolMapping(protocolVersion: ProtocolConstants.minecraft_1_8, packetID: 0x07),
            ProtocolMapping(protocolVersion: ProtocolConstants.minecraft_1_9, packetID: 0x33),
            ProtocolMapping(protocolVersion: ProtocolConstants.minecraft_1_12, packetID: 0x34),
            ProtocolMapping(protocolVersion: ProtocolConstants.minecraft_1_12_1, packetID: 0x35),
            ProtocolMapping(protocolVersion: ProtocolConstants.minecraft_1_13, packetID: 0x38),
            ProtocolMapping(protocolVersion: ProtocolConstants.minecraft_1_14, packetID: 0x3A),
            ProtocolMapping(protocolVersion: ProtocolConstants.minecraft_1_15, packetID: 0x3B)
        ])
        // ...
        to_client.registerPacket(packetClass: MapChunk.self, mappings: [
            ProtocolMapping(protocolVersion: ProtocolConstants.minecraft_1_8, packetID: 0x21),
            ProtocolMapping(protocolVersion: ProtocolConstants.minecraft_1_9, packetID: 0x20),
            ProtocolMapping(protocolVersion: ProtocolConstants.minecraft_1_13, packetID: 0x22),
            ProtocolMapping(protocolVersion: ProtocolConstants.minecraft_1_14, packetID: 0x21),
            ProtocolMapping(protocolVersion: ProtocolConstants.minecraft_1_15, packetID: 0x22)
        ])
        // ...
        to_client.registerPacket(packetClass: PlayerInfo.self, mappings: [
            ProtocolMapping(protocolVersion: ProtocolConstants.minecraft_1_8, packetID: 0x38),
            ProtocolMapping(protocolVersion: ProtocolConstants.minecraft_1_9, packetID: 0x2D),
            ProtocolMapping(protocolVersion: ProtocolConstants.minecraft_1_12_1, packetID: 0x2E),
            ProtocolMapping(protocolVersion: ProtocolConstants.minecraft_1_13, packetID: 0x30),
            ProtocolMapping(protocolVersion: ProtocolConstants.minecraft_1_14, packetID: 0x33),
            ProtocolMapping(protocolVersion: ProtocolConstants.minecraft_1_15, packetID: 0x34)
        ])
        // ...
        to_client.registerPacket(packetClass: PluginMessage.self, mappings: [
            ProtocolMapping(protocolVersion: ProtocolConstants.minecraft_1_8, packetID: 0x3F),
            ProtocolMapping(protocolVersion: ProtocolConstants.minecraft_1_9, packetID: 0x18),
            ProtocolMapping(protocolVersion: ProtocolConstants.minecraft_1_13, packetID: 0x19),
            ProtocolMapping(protocolVersion: ProtocolConstants.minecraft_1_14, packetID: 0x18),
            ProtocolMapping(protocolVersion: ProtocolConstants.minecraft_1_15, packetID: 0x19)
        ])
        to_client.registerPacket(packetClass: Kick.self, mappings: [
            ProtocolMapping(protocolVersion: ProtocolConstants.minecraft_1_8, packetID: 0x40),
            ProtocolMapping(protocolVersion: ProtocolConstants.minecraft_1_9, packetID: 0x1A),
            ProtocolMapping(protocolVersion: ProtocolConstants.minecraft_1_13, packetID: 0x1B),
            ProtocolMapping(protocolVersion: ProtocolConstants.minecraft_1_14, packetID: 0x1A),
            ProtocolMapping(protocolVersion: ProtocolConstants.minecraft_1_15, packetID: 0x1B)
        ])
        // ...
        to_client.registerPacket(packetClass: PlayerListHeaderFooter.self, mappings: [
            ProtocolMapping(protocolVersion: ProtocolConstants.minecraft_1_8, packetID: 0x47),
            ProtocolMapping(protocolVersion: ProtocolConstants.minecraft_1_9, packetID: 0x48),
            ProtocolMapping(protocolVersion: ProtocolConstants.minecraft_1_9_4, packetID: 0x47),
            ProtocolMapping(protocolVersion: ProtocolConstants.minecraft_1_12, packetID: 0x49),
            ProtocolMapping(protocolVersion: ProtocolConstants.minecraft_1_12_1, packetID: 0x4A),
            ProtocolMapping(protocolVersion: ProtocolConstants.minecraft_1_13, packetID: 0x4E),
            ProtocolMapping(protocolVersion: ProtocolConstants.minecraft_1_14, packetID: 0x53),
            ProtocolMapping(protocolVersion: ProtocolConstants.minecraft_1_15, packetID: 0x54)
        ])
        // ...
        to_client.registerPacket(packetClass: GameState.self, mappings: [
            ProtocolMapping(protocolVersion: ProtocolConstants.minecraft_1_8, packetID: 0x2B),
            ProtocolMapping(protocolVersion: ProtocolConstants.minecraft_1_9, packetID: 0x1E),
            ProtocolMapping(protocolVersion: ProtocolConstants.minecraft_1_13, packetID: 0x20),
            ProtocolMapping(protocolVersion: ProtocolConstants.minecraft_1_14, packetID: 0x1E),
            ProtocolMapping(protocolVersion: ProtocolConstants.minecraft_1_15, packetID: 0x1F)
        ])
        // ...
        to_client.registerPacket(packetClass: Position.self, mappings: [
            ProtocolMapping(protocolVersion: ProtocolConstants.minecraft_1_8, packetID: 0x08),
            ProtocolMapping(protocolVersion: ProtocolConstants.minecraft_1_9, packetID: 0x2E),
            ProtocolMapping(protocolVersion: ProtocolConstants.minecraft_1_12_1, packetID: 0x2F),
            ProtocolMapping(protocolVersion: ProtocolConstants.minecraft_1_13, packetID: 0x32),
            ProtocolMapping(protocolVersion: ProtocolConstants.minecraft_1_14, packetID: 0x35),
            ProtocolMapping(protocolVersion: ProtocolConstants.minecraft_1_15, packetID: 0x36)
        ])
        // ...
        to_server.registerPacket(packetClass: KeepAlive.self, mappings: [
            ProtocolMapping(protocolVersion: ProtocolConstants.minecraft_1_8, packetID: 0x00),
            ProtocolMapping(protocolVersion: ProtocolConstants.minecraft_1_9, packetID: 0x0B),
            ProtocolMapping(protocolVersion: ProtocolConstants.minecraft_1_12, packetID: 0x0C),
            ProtocolMapping(protocolVersion: ProtocolConstants.minecraft_1_12_1, packetID: 0x0B),
            ProtocolMapping(protocolVersion: ProtocolConstants.minecraft_1_14, packetID: 0x0F)
        ])
        to_server.registerPacket(packetClass: Chat.self, mappings: [
            ProtocolMapping(protocolVersion: ProtocolConstants.minecraft_1_8, packetID: 0x01),
            ProtocolMapping(protocolVersion: ProtocolConstants.minecraft_1_9, packetID: 0x02),
            ProtocolMapping(protocolVersion: ProtocolConstants.minecraft_1_12, packetID: 0x03),
            ProtocolMapping(protocolVersion: ProtocolConstants.minecraft_1_12_1, packetID: 0x02),
            ProtocolMapping(protocolVersion: ProtocolConstants.minecraft_1_14, packetID: 0x03)
        ])
        // ...
        to_server.registerPacket(packetClass: PlayerPosition.self, mappings: [
            ProtocolMapping(protocolVersion: ProtocolConstants.minecraft_1_8, packetID: 0x04),
            ProtocolMapping(protocolVersion: ProtocolConstants.minecraft_1_9, packetID: 0x0C),
            ProtocolMapping(protocolVersion: ProtocolConstants.minecraft_1_12, packetID: 0x0E),
            ProtocolMapping(protocolVersion: ProtocolConstants.minecraft_1_12_1, packetID: 0x0D),
            ProtocolMapping(protocolVersion: ProtocolConstants.minecraft_1_13, packetID: 0x10),
            ProtocolMapping(protocolVersion: ProtocolConstants.minecraft_1_14, packetID: 0x11)
        ])
        to_server.registerPacket(packetClass: PlayerLook.self, mappings: [
            ProtocolMapping(protocolVersion: ProtocolConstants.minecraft_1_8, packetID: 0x05),
            ProtocolMapping(protocolVersion: ProtocolConstants.minecraft_1_9, packetID: 0x0E),
            ProtocolMapping(protocolVersion: ProtocolConstants.minecraft_1_12, packetID: 0x10),
            ProtocolMapping(protocolVersion: ProtocolConstants.minecraft_1_12_1, packetID: 0x0F),
            ProtocolMapping(protocolVersion: ProtocolConstants.minecraft_1_13, packetID: 0x12),
            ProtocolMapping(protocolVersion: ProtocolConstants.minecraft_1_14, packetID: 0x13)
        ])
        to_server.registerPacket(packetClass: PlayerPositionLook.self, mappings: [
            ProtocolMapping(protocolVersion: ProtocolConstants.minecraft_1_8, packetID: 0x06),
            ProtocolMapping(protocolVersion: ProtocolConstants.minecraft_1_9, packetID: 0x0D),
            ProtocolMapping(protocolVersion: ProtocolConstants.minecraft_1_12, packetID: 0x0F),
            ProtocolMapping(protocolVersion: ProtocolConstants.minecraft_1_12_1, packetID: 0x0E),
            ProtocolMapping(protocolVersion: ProtocolConstants.minecraft_1_13, packetID: 0x11),
            ProtocolMapping(protocolVersion: ProtocolConstants.minecraft_1_14, packetID: 0x12)
        ])
        // ...
        to_server.registerPacket(packetClass: PluginMessage.self, mappings: [
            ProtocolMapping(protocolVersion: ProtocolConstants.minecraft_1_8, packetID: 0x17),
            ProtocolMapping(protocolVersion: ProtocolConstants.minecraft_1_9, packetID: 0x09),
            ProtocolMapping(protocolVersion: ProtocolConstants.minecraft_1_12, packetID: 0x0A),
            ProtocolMapping(protocolVersion: ProtocolConstants.minecraft_1_12_1, packetID: 0x09),
            ProtocolMapping(protocolVersion: ProtocolConstants.minecraft_1_13, packetID: 0x0A),
            ProtocolMapping(protocolVersion: ProtocolConstants.minecraft_1_14, packetID: 0x0B)
        ])
    }
    static let STATUS = Prot(name: "STATUS") { to_server, to_client in
        to_client.registerPacket(packetClass: StatusResponse.self, mappings: [
            ProtocolMapping(protocolVersion: ProtocolConstants.minecraft_1_8, packetID: 0x00)
        ])
        to_client.registerPacket(packetClass: PingPacket.self, mappings: [
            ProtocolMapping(protocolVersion: ProtocolConstants.minecraft_1_8, packetID: 0x01)
        ])
        to_server.registerPacket(packetClass: StatusRequest.self, mappings: [
            ProtocolMapping(protocolVersion: ProtocolConstants.minecraft_1_8, packetID: 0x00)
        ])
        to_server.registerPacket(packetClass: PingPacket.self, mappings: [
            ProtocolMapping(protocolVersion: ProtocolConstants.minecraft_1_8, packetID: 0x01)
        ])
    }
    static let LOGIN = Prot(name: "LOGIN") { to_server, to_client in
        to_client.registerPacket(packetClass: Kick.self, mappings: [
            ProtocolMapping(protocolVersion: ProtocolConstants.minecraft_1_8, packetID: 0x00)
        ])
        to_client.registerPacket(packetClass: EncryptionRequest.self, mappings: [
            ProtocolMapping(protocolVersion: ProtocolConstants.minecraft_1_8, packetID: 0x01)
        ])
        // ...
        to_client.registerPacket(packetClass: LoginSuccess.self, mappings: [
            ProtocolMapping(protocolVersion: ProtocolConstants.minecraft_1_8, packetID: 0x02)
        ])
        to_client.registerPacket(packetClass: SetCompression.self, mappings: [
            ProtocolMapping(protocolVersion: ProtocolConstants.minecraft_1_8, packetID: 0x03)
        ])
        // ...
        to_server.registerPacket(packetClass: LoginRequest.self, mappings: [
            ProtocolMapping(protocolVersion: ProtocolConstants.minecraft_1_8, packetID: 0x00)
        ])
        to_server.registerPacket(packetClass: EncryptionResponse.self, mappings: [
            ProtocolMapping(protocolVersion: ProtocolConstants.minecraft_1_8, packetID: 0x01)
        ])
    }
    
    // Variables
    static let max_packet_id: Int32 = 0xFF
    var name: String
    var to_server: DirectionData!
    var to_client: DirectionData!
    
    // Initializer
    init(name: String, completionHandler: @escaping (DirectionData, DirectionData) -> ()) {
        self.name = name
        self.to_server = DirectionData(prot: self, direction: .to_server)
        self.to_client = DirectionData(prot: self, direction: .to_client)
        completionHandler(to_server, to_client)
    }
    
    // Equatable
    static func == (lhs: Prot, rhs: Prot) -> Bool {
        return lhs.name == rhs.name
    }
    
    
}
