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

public class PlayerListHeaderFooter: Packet {
    
    public var header: String
    public var footer: String
    
    public required init() {
        header = ""
        footer = ""
    }
    
    public init(header: String, footer: String) {
        self.header = header
        self.footer = footer
    }
    
    public func readPacket(from buffer: inout ByteBuffer, direction: DirectionData, protocolVersion: Int32) {
        header = buffer.readVarString() ?? header
        footer = buffer.readVarString() ?? footer
    }
    
    public func writePacket(to buffer: inout ByteBuffer, direction: DirectionData, protocolVersion: Int32) {
        buffer.writeVarString(string: header)
        buffer.writeVarString(string: footer)
    }
    
    public func toString() -> String {
        return "PlayerListHeaderFooter(header: \(header), footer: \(footer))"
    }
    
}
