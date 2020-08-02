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

public class KeepAlive: Packet {
    
    public var randomId: Int64
    
    public required init() {
        randomId = 0
    }
    
    public func readPacket(from buffer: inout ByteBuffer, direction: DirectionData, protocolVersion: Int32) {
        randomId = protocolVersion >= ProtocolConstants.minecraft_1_12_2 ?
            buffer.readInteger(as: Int64.self) ?? randomId :
            Int64(buffer.readVarInt() ?? Int32(randomId))
    }
    
    public func writePacket(to buffer: inout ByteBuffer, direction: DirectionData, protocolVersion: Int32) {
        if protocolVersion >= ProtocolConstants.minecraft_1_12_2 {
            buffer.writeInteger(randomId)
        } else {
            buffer.writeVarInt(value: Int32(randomId))
        }
    }
    
    public func toString() -> String {
        return "KeepAlive(randomId: \(randomId))"
    }
    
}
