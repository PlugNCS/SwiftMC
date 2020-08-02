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

public class BlockPlace: Packet {
    
    public var position: UInt64
    public var direction: Int8
    
    public required init() {
        position = 0
        direction = 0
    }
    
    public init(position: UInt64, direction: Int8) {
        self.position = position
        self.direction = 0
    }
    
    public func readPacket(from buffer: inout ByteBuffer, direction: DirectionData, protocolVersion: Int32) {
        self.position = buffer.readInteger(as: UInt64.self) ?? self.position
        self.direction = buffer.readInteger(as: Int8.self) ?? self.direction
    }
    
    public func writePacket(to buffer: inout ByteBuffer, direction: DirectionData, protocolVersion: Int32) {
        buffer.writeInteger(self.position, as: UInt64.self)
        buffer.writeInteger(self.direction, as: Int8.self)
    }
    
    public func toString() -> String {
        return "BlockPlace(x: \(position >> 38), y: \(position & 0xFFF), z: \((position << 26) >> 38), direction: \(direction))"
    }
    
}
