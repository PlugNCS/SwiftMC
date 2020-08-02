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

public class VariableValueArray {
    
    // Calculation
    public static func neededBits(for number: Int) -> Int {
        var number = number
        var count = 0
        repeat {
            count += 1
            number = number >> 1
        } while number != 0
        return count
    }
    
    // Storage
    internal var backing: [Int64]
    internal let capacity: Int
    internal let bitsPerValue: Int
    internal let valueMask: Int64
    
    // Initializer
    public init(bitsPerValue: Int, capacity: Int) {
        self.backing = [Int64](repeating: 0, count: Int(ceil(Double(bitsPerValue * capacity) / 64.0)))
        self.bitsPerValue = bitsPerValue
        self.valueMask = (1 << bitsPerValue) - 1
        self.capacity = capacity
    }
    
    // Largest possible value
    public func largestPossibleValue() -> Int64 {
        return valueMask
    }
    
    // Get and set a value
    public subscript(index: Int) -> Int32 {
        get {
            let index = index * bitsPerValue
            let i0 = index >> 6
            let i1 = index & 0x3F
            let i2 = i1 + bitsPerValue
            
            var value = Int64(bitPattern: UInt64(bitPattern: backing[i0]) >> UInt64(bitPattern: Int64(i1)))
            
            if i2 > 64 {
                value |= backing[i0 + 1] << Int64(64 - i1)
            }
            
            return Int32(value & valueMask)
        }
        set {
            let value = Int64(newValue)
            let index = index * bitsPerValue
            var i0 = index >> 6
            let i1 = index & 0x3F
            let i2 = i1 + bitsPerValue
            
            let p1 = backing[i0] & ~(valueMask << i1)
            let p2 = (value & valueMask) << i1
            backing[i0] = p1 | p2
            
            if i2 > 64 {
                i0 += 1
                let p3 = ~((1 << i2 - 64) - 1)
                let p4 = value >> Int64(64 - i1)
                backing[i0] = backing[i0] & Int64(p3) | p4
            }
        }
    }
    
    // Increase the bits per value
    public func increaseBitsPerValue(to newBitsPerValue: Int) -> VariableValueArray {
        let returned = VariableValueArray(bitsPerValue: newBitsPerValue, capacity: capacity)
        for i in 0 ..< capacity {
            returned[i] = self[i]
        }
        return returned
    }
    
}
