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

public class NBTLong: NBTTag {
    
    public var name: String?
    public var value: Int64
    
    public required init() {
        value = 0
    }
    
    public init(name: String?, value: Int64) {
        self.name = name
        self.value = value
    }
    
    public func readTag(from buffer: inout ByteBuffer) {
        self.value = buffer.readInteger(as: Int64.self) ?? value
    }
    
    public func writeTag(to buffer: inout ByteBuffer) {
        buffer.writeInteger(value)
    }
    
    public func toString() -> String {
        return "NBTLong(name: \(name ?? "NONE"), value: \(value))"
    }
    
    public func contentSize() -> Int {
        return 8
    }
    
}
