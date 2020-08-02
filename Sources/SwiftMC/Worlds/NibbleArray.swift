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

public class NibbleArray {
    
    // Storage
    internal var rawData: [Int8]
    
    // Initializer
    public init(size: Int, value: Int8 = 0) {
        let size = size % 2 == 0 ? size : size + 1
        if value != 0 {
            let value = value & 0x0F
            self.rawData = [Int8](repeating: value << 4 | value, count: size / 2)
        } else {
            self.rawData = [Int8](repeating: 0, count: size / 2)
        }
    }
    
    // Init from existing data
    public init(rawData: [Int8]) {
        self.rawData = rawData
    }
    
    // Get size
    public func count() -> Int {
        return 2 * rawData.count
    }
    
    // Get size in bytes
    public func byteCount() -> Int {
        return rawData.count
    }
    
    // Get and set a value
    public subscript(index: Int) -> Int8 {
        get {
            let val = UInt8(bitPattern: rawData[index / 2])
            if index % 2 == 0 {
                return Int8(bitPattern: val & 0x0F)
            } else {
                return Int8(bitPattern: (val & 0x0F) >> 4)
            }
        }
        set {
            let value = UInt8(bitPattern: newValue & 0x0F)
            let half = index / 2
            let previous = UInt8(bitPattern: rawData[half])
            if index % 2 == 0 {
                rawData[half] = Int8(bitPattern: previous & 0xF0 | value)
            } else {
                rawData[half] = Int8(bitPattern: previous & 0x0F | value << 4)
            }
        }
    }
    
}
