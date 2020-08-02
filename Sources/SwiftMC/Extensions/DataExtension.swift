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

extension Data {
    
    public func bin2hex() -> String {
        var string = ""
        for byte in [UInt8](self) {
            string += String(format: "%02hhx", byte)
        }
        return string
    }
    
    public func toSignedHexString() -> String {
        // Create an empty string
        var result = ""
        var first: Int8 = 0
        
        // Iterate bytes
        var bytes = map { byte in
            // Convert to Int8
            return Int8(bitPattern: byte)
        }
        while !bytes.isEmpty {
            // Get and remove the first byte
            let byte = bytes.removeFirst()
            
            // Check if this byte is the first byte
            if result.isEmpty && first == 0 {
                // Save the first byte
                first = byte
            } else if result.isEmpty && first != 0 {
                // Convert two first bytes to hex
                result.append(String(Int32(first + (byte < 0 ? 1 : 0)) * 256 + Int32(byte) + (first < 0 ? 1 : 0), radix: 16, uppercase: false))
            } else {
                // Convert it to hex
                result.append(String(format: "%02hhx", first < 0 ? (Int32(bytes.isEmpty ? 256 : 255) - Int32(byte)) % 256 : byte))
            }
        }
        
        // Return the final result
        return result
    }
    
    init<T>(from value: T) where T: FixedWidthInteger {
        self = Swift.withUnsafeBytes(of: value.bigEndian) { Data($0) }
    }

    func to<T>(type: T.Type) -> T? where T: FixedWidthInteger {
        var value: T = 0
        guard count >= MemoryLayout.size(ofValue: value) else { return nil }
        _ = Swift.withUnsafeMutableBytes(of: &value, { copyBytes(to: $0)} )
        return value.bigEndian
    }
    
}
