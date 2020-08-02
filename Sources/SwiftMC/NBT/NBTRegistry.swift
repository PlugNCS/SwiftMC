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

class NBTRegistry {
    
    // Map of ID <=> Tag
    private static var nbtMap = [
        // End tag
        0: NBTEnd.self,
        
        // Byte
        1: NBTByte.self,
        
        // Integers
        2: NBTShort.self,
        3: NBTInt.self,
        4: NBTLong.self,
        
        // Floating numbers
        5: NBTFloat.self,
        6: NBTDouble.self,
        
        // Byte array
        7: NBTByteArray.self,
        
        // String
        8: NBTString.self,
        
        // Lists
        9: NBTList.self,
        10: NBTCompound.self,
        
        // Integer arrays
        11: NBTIntArray.self,
        12: NBTLongArray.self
    ] as [UInt8: NBTTag.Type]
    
    // Create a tag from id
    public static func createTag(id: UInt8, name: String? = nil) -> NBTTag {
        if let tag = nbtMap[id]?.init(name: name) {
            return tag
        }
        return NBTEnd()
    }
    
    // Get id from a tag
    public static func getId(for tag: NBTTag.Type) -> UInt8? {
        return nbtMap.first { item in
            return item.value == tag
        }?.key
    }
    
    // Read a tag
    public static func readTag(in buffer: inout ByteBuffer) -> NBTTag {
        // Get tag id
        let id = buffer.readBytes(length: 1)?.first ?? 0
        
        // Return if it is an end tag
        if id == 0 {
            return NBTEnd()
        }
        
        // Read the tag name
        let name = buffer.readShortPrefixedString()
        
        // Create a tag
        let tag = createTag(id: id, name: name)
        
        // Read the tag
        tag.readTag(from: &buffer)
        
        // And return it
        return tag
    }
    
    // Write a tag
    public static func writeTag(tag: NBTTag, to buffer: inout ByteBuffer) {
        // Get tag id
        let id = getId(for: type(of: tag)) ?? 0
        
        // Write the tag id
        buffer.writeBytes([id])
        
        // Return if it is an end tag
        if id == 0 {
            return
        }
        
        // Write the tag name
        buffer.writeShortPrefixedString(string: tag.name ?? "")
        
        // Write the tag content
        tag.writeTag(to: &buffer)
    }
    
}
