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

public class Random {
    
    // Store the random seed
    private var seed: Int64
    
    // Initializer
    public init(seed: Int64 = Int64.random(in: Int64.min ..< Int64.max)) {
        self.seed = (seed ^ 0x5DEECE66D) & ((1 << 48) - 1)
    }
    
    // Set the seed
    public func setSeed(to seed: Int64) {
        self.seed = (seed ^ 0x5DEECE66D) & ((1 << 48) - 1)
    }
    
    // Get the seed
    public func getSeed() -> Int64 {
        return seed
    }
    
    // Next element bits
    private func next(bits: Int) -> Int64 {
        self.seed = (seed &* 0x5DEECE66D &+ 0xB) & ((1 << 48) - 1)
        return Int64(bitPattern: UInt64(bitPattern: seed) >> (48 - bits))
    }
    
    // Random Int32
    public func nextInt32() -> Int32 {
        return Int32(next(bits: 31))
    }
    
    // Random Int32 with bounds
    public func nextInt32(bound: Int32) -> Int32 {
        if bound <= 0 { return 0 }

        if (bound & -bound) == bound {
            return Int32((Int64(bound) * next(bits: 31)) >> 31)
        }

        var bits: Int32, val: Int32
        repeat {
            bits = Int32(next(bits: 31))
            val = bits % bound
        } while bits - val + (bound-1) < 0
        return val
    }
    
    // Random Int64
    public func nextInt64() -> Int64 {
        return (next(bits: 32) << 32) + next(bits: 32)
    }
    
    // Random Bool
    public func nextBool() -> Bool {
        return next(bits: 1) != 0
    }
    
    // Random Float
    public func nextFloat() -> Float {
        return Float(next(bits: 24)) / Float(1 << 24)
    }
    
    // Random Double
    public func nextDouble() -> Double {
      return Double((next(bits: 26) << 27) + next(bits: 27)) / Double(1 << 53)
    }
    
}
