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

public class PerlinGenerator {
    
    var permutation = [Int]()
    
    public init(random: Random) {
        permutation = (0 ..< 512).map({ _ in Int(random.nextInt32(bound: 255)) })
    }
    
    func lerp(a: Float, b: Float, x: Float) -> Float {
        return a + x * (b - a) // This interpolates between two points with a weight x
    }
    
    func fade(t: Float) -> Float {
        return t * t * t * (t * (t * 6 - 15) + 10) // This is the smoothing function for Perlin noise
    }
    
    func grad(hash: Int, x: Float, y: Float) -> Float {
        // This takes a hash (a number from 0 - 5) generated from the random permutations and returns a random operation for the node to offset
        switch hash & 3 {
        case 0:
            return x + y
        case 1:
            return -x + y
        case 2:
            return x - y
        case 3:
            return -x - y
        default:
            return 0
        }
    }
    
    func fastfloor(x: Float) -> Int {
        return x > 0 ? Int(x) : Int(x-1)
    }
    
    public func noise(x: Float, y: Float) -> Float {
        // Find the unit grid cell containing the point
        var xi = fastfloor(x: x)
        var yi = fastfloor(x: y)
        
        // This is the other bound of the unit square
        let xf = x - Float(xi)
        let yf = y - Float(yi)
        
        // Wrap the ints around 255
        xi = xi & 255
        yi = yi & 255
        
        // These are offset values for interpolation
        let u = fade(t: xf)
        let v = fade(t: yf)
        
        // These are the 4 possible permutations so we get the perm value for each
        let aa = permutation[permutation[xi] + yi]
        let ab = permutation[permutation[xi] + yi + 1]
        let ba = permutation[permutation[xi + 1] + yi]
        let bb = permutation[permutation[xi + 1] + yi + 1]
        
        // We pair aa and ba, and ab and bb and lerp the gradient of the two, using the offset values
        // We take 1 off the value which we added one to for the perms
        let x1 = lerp(a: grad(hash: aa, x: xf, y: yf), b: grad(hash: ba, x: xf - 1, y: yf), x: u)
        let x2 = lerp(a: grad(hash: ab, x: xf, y: yf - 1), b: grad(hash: bb, x: xf - 1, y: yf - 1), x: u)
        let y1 = lerp(a: x1, b: x2, x: v)
        
        // We return the value + 1 / 2 to remove any negatives.
        return (y1 + 1) / 2
    }
    
    public func octaveNoise(x: Float, y: Float, octaves: Int, persistence: Float) -> Float {
        // This takes several perlin readings (n octaves) and merges them into one map
        var total: Float = 0
        var frequency: Float = 1
        var amplitude: Float = 1
        var maxValue: Float = 0
        
        // We sum the total and divide by the max at the end to normalise
        for _ in 0 ..< octaves {
            total += noise(x: x * frequency, y: y * frequency) * amplitude
            maxValue += amplitude
            
            // This is taken from recomendations on values
            amplitude *= persistence
            frequency *= 2
        }
        
        return total/maxValue
    }

}
