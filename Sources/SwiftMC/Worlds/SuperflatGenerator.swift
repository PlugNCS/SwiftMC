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

public class SuperflatGenerator: WorldGenerator {
    
    public func generateBiomes(world: LocalWorld, random: Random, chunkX: Int32, chunkZ: Int32) -> [Int8] {
        return [Int8](repeating: 1, count: 256)
    }
    
    public func generateChunkData(world: LocalWorld, random: Random, chunkX: Int32, chunkZ: Int32, biomes: [Int8]) -> WorldChunkData {
        let chunkData = WorldChunkData(world: world)
        
        for x: Int32 in 0 ..< 16 {
            for z: Int32 in 0 ..< 16 {
                for y: Int32 in 0 ..< 64 {
                    if y < 4 {
                        chunkData.setBlock(x: x, y: y, z: z, material: .bedrock)
                    } else if y < 60 {
                        chunkData.setBlock(x: x, y: y, z: z, material: .stone)
                    } else if y < 63 {
                        chunkData.setBlock(x: x, y: y, z: z, material: .dirt)
                    } else if y < 64 {
                        chunkData.setBlock(x: x, y: y, z: z, material: .grass)
                    }
                }
            }
        }
        
        return chunkData
    }
    
    public func getName() -> String {
        return "superflat"
    }
    
}
