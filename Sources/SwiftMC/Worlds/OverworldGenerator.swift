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

public class OverworldGenerator: WorldGenerator {
    
    public func generateBiomes(world: LocalWorld, random: Random, chunkX: Int32, chunkZ: Int32) -> [Int8] {
        let perlin = PerlinGenerator(random: random)
        var biomes = [Int8]()
        
        for z: Int32 in 0 ..< 16 {
            for x: Int32 in 0 ..< 16 {
                biomes.append(Int8(perlin.octaveNoise(x: Float(chunkX * 16 + x) / 500, y: Float(chunkZ * 16 + z) / 500, octaves: 1, persistence: 0.5) * 22))
            }
        }
        
        return biomes
    }
    
    public func generateChunkData(world: LocalWorld, random: Random, chunkX: Int32, chunkZ: Int32, biomes: [Int8]) -> WorldChunkData {
        var chunkData = WorldChunkData(world: world)
        let perlin = PerlinGenerator(random: random)
        
        for x: Int32 in 0 ..< 16 {
            for z: Int32 in 0 ..< 16 {
                generateColumn(in: &chunkData, with: perlin, x: x, chunkX: chunkX, z: z, chunkZ: chunkZ, biome: biomes[Int(x | z << 4)])
            }
        }
        
        return chunkData
    }
    
    public func getName() -> String {
        return "overworld"
    }
    
    public func generateColumn(in chunkData: inout WorldChunkData, with perlin: PerlinGenerator, x: Int32, chunkX: Int32, z: Int32, chunkZ: Int32, biome: Int8) {
        let h = Int32(perlin.octaveNoise(x: Float(chunkX * 16 + x) / 100, y: Float(chunkZ * 16 + z) / 100, octaves: 3, persistence: 0.5) * 30 + 50)
        for y: Int32 in 0 ..< max(h, 63) {
            if y < 4 {
                // Always bedrock
                chunkData.setBlock(x: x, y: y, z: z, material: .bedrock)
            } else if y < h - 10 || h > 70 {
                // Stone until a change
                chunkData.setBlock(x: x, y: y, z: z, material: .stone)
            } else if y < h - 1 {
                // Check if we are under a lake
                if h < 63 {
                    // Sandstone
                    chunkData.setBlock(x: x, y: y, z: z, blockId: 24)
                } else {
                    // Some dirt
                    chunkData.setBlock(x: x, y: y, z: z, material: .dirt)
                }
            } else if y < h {
                // Check if we are under a lake
                if h < 63 {
                    // Sandstone
                    chunkData.setBlock(x: x, y: y, z: z, blockId: 12)
                } else {
                    // And grass
                    chunkData.setBlock(x: x, y: y, z: z, material: .grass)
                }
            } else {
                // Fill missing blocks with water
                chunkData.setBlock(x: x, y: y, z: z, blockId: 8)
            }
        }
    }
    
}
