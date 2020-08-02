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

public class GameState: Packet {
    
    public static let change_gamemode: UInt8 = 3
    public static let immediate_respawn: UInt8 = 11
    
    public var reason: UInt8
    public var value: Float32
    
    public required init() {
        reason = 0
        value = 0
    }
    
    public init(reason: UInt8, value: Float32) {
        self.reason = reason
        self.value = value
    }
    
    public func readPacket(from buffer: inout ByteBuffer, direction: DirectionData, protocolVersion: Int32) {
        self.reason = buffer.readBytes(length: 1)?.first ?? reason
        self.value = buffer.readFloat() ?? value
    }
    
    public func writePacket(to buffer: inout ByteBuffer, direction: DirectionData, protocolVersion: Int32) {
        buffer.writeBytes([reason])
        buffer.writeFloat(value: value)
    }
    
    public func toString() -> String {
        return "GameState(reason: \(reason), value: \(value))"
    }
    
}
