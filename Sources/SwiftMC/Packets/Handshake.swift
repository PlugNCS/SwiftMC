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

public class Handshake: Packet {
    
    public var protocolVersion: Int32
    public var host: String
    public var port: Int16
    public var requestedProtocol: Int32
    
    public required init() {
        protocolVersion = -1
        host = ""
        port = -1
        requestedProtocol = -1
    }
    
    public init(protocolVersion: Int32, host: String, port: Int16, requestedProtocol: Int32) {
        self.protocolVersion = protocolVersion
        self.host = host
        self.port = port
        self.requestedProtocol = requestedProtocol
    }
    
    public func readPacket(from buffer: inout ByteBuffer, direction: DirectionData, protocolVersion: Int32) {
        self.protocolVersion = buffer.readVarInt() ?? self.protocolVersion
        self.host = buffer.readVarString() ?? self.host
        self.port = buffer.readInteger(as: Int16.self) ?? self.port
        self.requestedProtocol = buffer.readVarInt() ?? self.requestedProtocol
    }
    
    public func writePacket(to buffer: inout ByteBuffer, direction: DirectionData, protocolVersion: Int32) {
        buffer.writeVarInt(value: protocolVersion)
        buffer.writeVarString(string: host)
        buffer.writeInteger(port)
        buffer.writeVarInt(value: requestedProtocol)
    }
    
    public func toString() -> String {
        return "Handshake(protocolVersion: \(protocolVersion), host: \(host), port: \(port), requestedProtocol: \(requestedProtocol))"
    }
    
}
