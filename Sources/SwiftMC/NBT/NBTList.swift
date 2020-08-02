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

public class NBTList: NBTTag {
    
    public var name: String?
    public var values: [NBTTag]
    
    public required init() {
        values = []
    }
    
    public init(name: String?, values: [NBTTag]) {
        self.name = name
        self.values = values
    }
    
    public func readTag(from buffer: inout ByteBuffer) {
        let id = buffer.readBytes(length: 1)?.first ?? 0
        let count = Int(buffer.readInteger(as: Int32.self) ?? 0)
        for _ in 0 ..< count {
            let tag = NBTRegistry.createTag(id: id)
            tag.readTag(from: &buffer)
            values.append(tag)
        }
    }
    
    public func writeTag(to buffer: inout ByteBuffer) {
        buffer.writeBytes([NBTRegistry.getId(for: type(of: values.first ?? NBTEnd())) ?? 0])
        buffer.writeInteger(Int32(values.count), as: Int32.self)
        for value in values {
            value.writeTag(to: &buffer)
        }
    }
    
    public func toString() -> String {
        return "NBTList(name: \(name ?? "NONE"), values:\n\(values.map({ $0.toString() }).joined(separator: "\n").indent())\n)"
    }
    
    public func contentSize() -> Int {
        return values.map({ $0.contentSize() }).reduce(5, { $0 + $1 })
    }
    
}
