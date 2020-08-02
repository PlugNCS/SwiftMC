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

extension ByteBuffer {
    
    public mutating func readVarString() -> String? {
        let len = readVarInt() ?? 0
        return readString(length: Int(len))
    }
    
    public mutating func writeVarString(string: String) {
        writeVarInt(value: Int32(string.utf8.count))
        writeString(string)
    }
    
    public mutating func readShortPrefixedString() -> String? {
        let len = readInteger(as: UInt16.self) ?? 0
        return readString(length: Int(len))
    }
    
    public mutating func writeShortPrefixedString(string: String) {
        writeInteger(UInt16(string.utf8.count), as: UInt16.self)
        writeString(string)
    }
    
    public mutating func readVarInt(maxBytes: Int = 5) -> Int32? {
        var out: Int32 = 0
        var bytes = 0
        while true {
            if let i = readBytes(length: 1)?.first {
                out |= (Int32(i) & 0x7F) << (bytes * 7)
                bytes += 1
                if bytes > maxBytes {
                    return nil
                }
                if (i & 0x80) != 0x80 {
                    break
                }
            } else {
                return nil
            }
        }
        return out
    }
    
    public mutating func writeVarInt(value: Int32) {
        var part: Int32
        var value = value
        while true {
            part = value & 0x7F
            value = value >> 7
            if value != 0 {
                part |= 0x80
            }
            writeBytes([UInt8(part)])
            if value == 0 {
                break
            }
        }
    }
    
    public mutating func readArray() -> [UInt8]? {
        let len = readVarInt() ?? 0
        return readBytes(length: Int(len))
    }
    
    public mutating func writeArray(value: [UInt8]) {
        writeVarInt(value: Int32(value.count))
        writeBytes(value)
    }
    
    public mutating func readBool() -> Bool? {
        return readBytes(length: MemoryLayout<Bool>.size)?.reversed().withUnsafeBufferPointer {
            $0.baseAddress!.withMemoryRebound(to: Bool.self, capacity: 1) {
                $0.pointee
            }
        }
    }
    
    public mutating func writeBool(value: Bool) {
        var value = value
        writeBytes(withUnsafePointer(to: &value) {
            $0.withMemoryRebound(to: UInt8.self, capacity: MemoryLayout<Bool>.size) {
                Array(UnsafeBufferPointer(start: $0, count: MemoryLayout<Bool>.size))
            }
        }.reversed())
    }
    
    public mutating func readDouble() -> Double? {
        return readBytes(length: MemoryLayout<Double>.size)?.reversed().withUnsafeBufferPointer {
            $0.baseAddress!.withMemoryRebound(to: Double.self, capacity: 1) {
                $0.pointee
            }
        }
    }
    
    public mutating func writeDouble(value: Double) {
        var value = value
        writeBytes(withUnsafePointer(to: &value) {
            $0.withMemoryRebound(to: UInt8.self, capacity: MemoryLayout<Double>.size) {
                Array(UnsafeBufferPointer(start: $0, count: MemoryLayout<Double>.size))
            }
        }.reversed())
    }
    
    public mutating func readFloat() -> Float32? {
        return readBytes(length: MemoryLayout<Float32>.size)?.reversed().withUnsafeBufferPointer {
            $0.baseAddress!.withMemoryRebound(to: Float32.self, capacity: 1) {
                $0.pointee
            }
        }
    }
    
    public mutating func writeFloat(value: Float32) {
        var value = value
        writeBytes(withUnsafePointer(to: &value) {
            $0.withMemoryRebound(to: UInt8.self, capacity: MemoryLayout<Float32>.size) {
                Array(UnsafeBufferPointer(start: $0, count: MemoryLayout<Float32>.size))
            }
        }.reversed())
    }
    
    public mutating func readUUID() -> String? {
        if let bytes = readBytes(length: 16) {
            return Data(bytes).bin2hex().addSeparatorUUID()
        }
        return nil
    }
    
    public mutating func writeUUID(value: String) {
        writeBytes(value.replacingOccurrences(of: "-", with: "").hex2bin())
    }
    
    public mutating func readNBT() -> NBTTag {
        return NBTRegistry.readTag(in: &self)
    }
    
    public mutating func writeNBT(tag: NBTTag) {
        NBTRegistry.writeTag(tag: tag, to: &self)
    }
    
    public mutating func readSlot() -> Slot {
        let present = readBool() ?? false
        let id = present ? readVarInt() : nil
        let count = present ? readBytes(length: 1)?.first : nil
        let tag = present ? readNBT() : nil
        return Slot(present: present, id: id, count: count, tag: tag)
    }
    
    public mutating func writeSlot(slot: Slot) {
        if slot.present, let id = slot.id, let count = slot.count, let tag = slot.tag {
            writeBool(value: true)
            writeVarInt(value: id)
            writeBytes([count])
            writeNBT(tag: tag)
        } else {
            writeBool(value: false)
        }
    }
    
}
