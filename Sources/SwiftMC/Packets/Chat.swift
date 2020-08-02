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

public class Chat: Packet {
    
    public var message: String
    public var position: UInt8
    
    public required init() {
        message = ""
        position = 0
    }
    
    public init(message: String) {
        self.message = message
        self.position = 0
    }
    
    public init(message: ChatMessage) {
        self.message = message.toJSON() ?? "{}"
        self.position = 0
    }
    
    public func readPacket(from buffer: inout ByteBuffer, direction: DirectionData, protocolVersion: Int32) {
        message = buffer.readVarString() ?? message
        if direction.direction == .to_client {
            position = buffer.readBytes(length: 1)?.first ?? position
        }
    }
    
    public func writePacket(to buffer: inout ByteBuffer, direction: DirectionData, protocolVersion: Int32) {
        buffer.writeVarString(string: message)
        if direction.direction == .to_client {
            buffer.writeBytes([position])
        }
    }
    
    public func toString() -> String {
        return "Chat(message: \(message), position: \(position))"
    }
    
}
