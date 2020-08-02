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

public class NBTIntArray: NBTTag {
    
    public var name: String?
    public var values: [Int32]
    
    public required init() {
        values = []
    }
    
    public init(name: String?, values: [Int32]) {
        self.name = name
        self.values = values
    }
    
    public func readTag(from buffer: inout ByteBuffer) {
        let count = Int(buffer.readInteger(as: Int32.self) ?? 0)
        for _ in 0 ..< count {
            values.append(buffer.readInteger(as: Int32.self) ?? 0)
        }
    }
    
    public func writeTag(to buffer: inout ByteBuffer) {
        buffer.writeInteger(Int32(values.count), as: Int32.self)
        for value in values {
            buffer.writeInteger(value)
        }
    }
    
    public func toString() -> String {
        return "NBTIntArray(name: \(name ?? "NONE"), values: \(values))"
    }
    
    public func contentSize() -> Int {
        return 4 + (values.count * 4)
    }
    
}
