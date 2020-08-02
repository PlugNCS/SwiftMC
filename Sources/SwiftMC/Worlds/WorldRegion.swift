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

class WorldRegion {
    
    // Static constants
    public static let region_size: Int32 = 32
    public static let version_gzip: Int8 = 1
    public static let version_deflate: Int8 = 2
    public static let sector_bytes = 4096
    public static let sector_ints = sector_bytes / 4
    public static let chunk_header_size = 5
    
    // Region informations
    public let world: LocalWorld
    public let x: Int32
    public let z: Int32
    
    // Caching
    private var offsets: [Int32]
    private var chunkTimestamps: [Int32]
    private var fileHandle: FileHandle
    private var lastModified: Double
    private var sectorsUsed: [Bool]
    private var sizeDelta: Int
    
    // Initializer
    public init(world: LocalWorld, x: Int32, z: Int32) throws {
        // Region informations
        self.world = world
        self.x = x
        self.z = z
        self.offsets = [Int32](repeating: 0, count: WorldRegion.sector_ints)
        self.chunkTimestamps = [Int32](repeating: 0, count: WorldRegion.sector_ints)
        self.sizeDelta = 0
        
        // Check if the region folder exists
        let folder = world.path.appendingPathComponent("region")
        if !FileManager.default.fileExists(atPath: folder.path) {
            // Create a folder
            try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true, attributes: nil)
        }
        
        // Get the content of the file if exists
        let file = folder.appendingPathComponent("r.\(x).\(z).mca")
        if !FileManager.default.fileExists(atPath: file.path) {
            FileManager.default.createFile(atPath: file.path, contents: nil, attributes: nil)
        }
        self.fileHandle = try FileHandle(forUpdating: file)
        self.lastModified = (try? FileManager.default.attributesOfItem(atPath: file.path)[.modificationDate] as? NSDate)?.timeIntervalSince1970 ?? 0
        let initialLength = fileHandle.seekToEndOfFile()
        
        // Grow the file if it is not big enough (less than 8K)
        if lastModified == 0 || initialLength < 4096 {
            // New file or files under 4K
            sizeDelta = 2 * WorldRegion.sector_bytes
            fileHandle.seek(to: 0)
            fileHandle.write(Data(repeating: 0, count: sizeDelta))
        } else {
            // Grow again if needed
            fileHandle.seekToEndOfFile()
            if initialLength < 2 * WorldRegion.sector_bytes {
                // Still under 8K
                sizeDelta = 2 * WorldRegion.sector_bytes - Int(initialLength)
                fileHandle.write(Data(repeating: 0, count: sizeDelta))
            } else if (initialLength & UInt64(WorldRegion.sector_bytes - 1)) != 0 {
                // Not a multiple of 4K, grow it
                sizeDelta = Int(initialLength) & (WorldRegion.sector_bytes - 1)
                fileHandle.write(Data(repeating: 0, count: sizeDelta))
            }
        }
        
        // Setup available sector map
        fileHandle.seek(to: 0)
        let totalSectors = Int(ceil(Double(fileHandle.seekToEndOfFile()) / Double(WorldRegion.sector_bytes)))
        self.sectorsUsed = [Bool](repeating: false, count: totalSectors)
        self.sectorsUsed[0] = true
        self.sectorsUsed[1] = true
        
        // Read offset table and timestamp tables
        fileHandle.seek(to: 0)
        for i in 0 ..< WorldRegion.sector_ints {
            let offset = fileHandle.readData(ofLength: 4).to(type: Int32.self) ?? 0
            offsets[i] = offset
            
            let startSector = offset >> 8
            let numSectors = offset & 0xFF
            
            if offset != 0 && startSector >= 0 && startSector + numSectors <= totalSectors {
                for j in startSector ... startSector + numSectors {
                    if j < sectorsUsed.count {
                        sectorsUsed[Int(j)] = true
                    } else {
                        sectorsUsed.append(true)
                    }
                }
            }
        }
        for i in 0 ..< WorldRegion.sector_ints {
            chunkTimestamps[i] = fileHandle.readData(ofLength: 4).to(type: Int32.self) ?? 0
        }
    }
    
    // Get offset for a chunk
    private func getOffset(x: Int32, z: Int32) -> Int32 {
        return offsets[Int(x + (z << 5))]
    }
    
    // Set offset
    private func setOffset(x: Int32, z: Int32, offset: Int32) {
        offsets[Int(x + (z << 5))] = offset
        fileHandle.seek(to: UInt64(x + (z << 5)) << 2)
        fileHandle.write(Data(from: offset))
    }
    
    // Set timestamp
    private func setTimestamp(x: Int32, z: Int32, value: Int32) {
        chunkTimestamps[Int(x + (z << 5))] = value
        fileHandle.seek(to: UInt64(WorldRegion.sector_bytes + Int(x + (z << 5)) << 2))
        fileHandle.write(Data(from: value))
    }
    
    // Get buffer to read chunk
    private func getChunkBuffer(x: Int32, z: Int32) throws -> ByteBuffer? {
        // Check chunk offset
        let offset = getOffset(x: x, z: z)
        if offset == 0 { return nil }
        
        // Check sectors
        let totalSectors = sectorsUsed.count
        let sectorNumber = offset >> 8
        let numSectors = offset & 0xFF
        if sectorNumber + numSectors > totalSectors { return nil }
        
        // Read sectors
        self.fileHandle.seek(to: UInt64(Int(sectorNumber) * WorldRegion.sector_bytes))
        let length = Int(fileHandle.readData(ofLength: 4).to(type: Int32.self) ?? 0)
        if length > WorldRegion.sector_bytes * Int(numSectors) || length <= 0 { return nil }
        
        // Read compression information
        let version = fileHandle.readData(ofLength: 1).to(type: Int8.self)
        var data = ByteBufferAllocator().buffer(capacity: length - 1)
        data.writeBytes([UInt8](fileHandle.readData(ofLength: length - 1)))
        if version == WorldRegion.version_gzip {
            data = try data.decompress(with: .gzip)
        } else if version == WorldRegion.version_deflate {
            data = try data.decompress(with: .deflate)
        }
        
        // Return the final buffer
        return data
    }
    
    // Get a chunk (in region coordinates)
    public func loadChunk(x: Int32, z: Int32) -> EventLoopFuture<WorldChunk> {
        // Prepare the promise
        let ev = world.server.eventLoopGroup.next()
        let promise = ev.makePromise(of: WorldChunk.self)
        
        // Get the buffer
        var buffer = try? getChunkBuffer(x: x, z: z)
        
        // Do the work
        ev.execute {
            // Create the chunk
            let chunk = WorldChunk(x: WorldRegion.region_size * self.x + x, z: WorldRegion.region_size * self.z + z)
            
            // Get the chunk from NBT
            let level = (buffer?.readNBT() as? NBTCompound)?["Level"] as? NBTCompound
            
            // If data exists from NBT
            if let level = level, (level["xPos"] as? NBTInt)?.value == chunk.x, (level["zPos"] as? NBTInt)?.value == chunk.z {
                // Load properties
                // TODO: LastUpdate, InhabitedTime, TerrainPopulated
                
                // Load the sections
                if let sections = level["Sections"] as? NBTList {
                    for section in sections.values {
                        if let section = section as? NBTCompound, let y = section["Y"] as? NBTByte {
                            chunk.sections[y.value] = WorldChunkSection(tag: section)
                        }
                    }
                }
                
                // Read biomes and heightmap
                if let biomes = level["Biomes"] as? NBTByteArray {
                    chunk.biomes = biomes.values
                }
                // TODO: Heightmap
                
                // Read slime chunk
                // TODO
            } else {
                // Generate a new chunk
                let random = Random(seed: self.world.config.randomSeed)
                let generator = self.world.getGenerator()
                
                // Biomes and heightmap
                chunk.biomes = generator.generateBiomes(world: self.world, random: random, chunkX: chunk.x, chunkZ: chunk.z)
                // TODO: Heightmap
                
                // Chunk data
                let chunkData = generator.generateChunkData(world: self.world, random: random, chunkX: chunk.x, chunkZ: chunk.z, biomes: chunk.biomes)
                
                // Populate
                // TODO
                
                // Load the sections
                for y in 0 ..< WorldChunk.section_count {
                    // Check section
                    let section = chunkData.getSections()[y]
                    if !section.isEmpty {
                        chunk.sections[Int8(y)] = WorldChunkSection(types: section.map({ Int32($0) }))
                    }
                }
            }
            
            // Return the created chunk
            chunk.loaded = true
            return promise.succeed(chunk)
        }
        
        // Return the future result
        return promise.futureResult
    }
    
    // Get a chunk synchronously
    public func getChunk(x: Int32, z: Int32) -> WorldChunk? {
        return try? loadChunk(x: x, z: z).wait()
    }
    
    // Write a NBT to file
    private func writeChunkBuffer(x: Int32, z: Int32, tag: NBTCompound) throws {
        // Create a buffer
        var buffer = ByteBufferAllocator().buffer(capacity: 1024*1024)
        
        // Write the NBT tag
        buffer.writeNBT(tag: tag)
        
        // Compress with zlib (defalte)
        buffer = try buffer.compress(with: .deflate)
        
        // Get offset and sector information
        let offset = getOffset(x: x, z: z)
        var sectorNumber = offset >> 8
        let sectorsAllocated = offset & 0xFF
        let sectorsNeeded = (buffer.readableBytes + WorldRegion.chunk_header_size) / WorldRegion.sector_bytes + 1
        
        // Max size if 1 MB
        if sectorsNeeded >= 256 {
            return
        }
        
        // Check if we already have a sector
        if sectorNumber != 0 && sectorsAllocated == sectorsNeeded {
            // Overwrite old sector
            write(sector: sectorNumber, buffer: &buffer)
        } else {
            // Clear previous sector
            if sectorNumber != 0 {
                for j in sectorNumber ... sectorNumber + sectorsAllocated {
                    sectorsUsed[Int(j)] = false
                }
            }
            
            // Find free space to store this chunk
            sectorNumber = findNewSectorStart(for: sectorsNeeded)
            if sectorNumber == -1 {
                // Grow the file (because no free space)
                fileHandle.seekToEndOfFile()
                fileHandle.write(Data(repeating: 0, count: WorldRegion.sector_bytes * sectorsNeeded))
                
                // And update sector number
                sectorNumber = Int32(sectorsUsed.count)
            }
            
            // Update used sectors
            for j in sectorNumber ... sectorNumber + Int32(sectorsNeeded) {
                if j < sectorsUsed.count {
                    sectorsUsed[Int(j)] = true
                } else {
                    sectorsUsed.append(true)
                }
            }
            
            // Write the sectors
            write(sector: sectorNumber, buffer: &buffer)
            
            // Update offset and timestamp
            setOffset(x: x, z: z, offset: sectorNumber << 8 | Int32(sectorsNeeded))
            setTimestamp(x: x, z: z, value: Int32(Date().timeIntervalSince1970))
        }
    }
    
    // Convert a chunk to a NBT and save it
    public func saveChunk(chunk: WorldChunk, x: Int32, z: Int32) {
        // Create a tag
        let level_tag = NBTCompound(name: "Level")
        
        // Save properties
        level_tag.put(NBTInt(name: "xPos", value: chunk.x))
        level_tag.put(NBTInt(name: "zPos", value: chunk.z))
        level_tag.put(NBTLong(name: "LastUpdate", value: 0))
        //level_tag.put(NBTLong(name: "InhabitedTime", value: chunk.inhabitedTime))
        //level_tag.put(NBTByte(name: "TerrainPopulated", value: chunk.terrainPopulated ? 1 : 0))
        
        // Save sections
        let list = NBTList(name: "Sections")
        let maxY = (chunk.sections.map({ $0.key }).max() ?? 0) + 1
        for y in 0 ..< maxY {
            if let section = chunk.sections[y] {
                let section_tag = NBTCompound()
                section_tag.put(NBTByte(name: "Y", value: y))
                section.optimize()
                section.save(to: section_tag)
                list.values.append(section_tag)
            }
        }
        level_tag.put(list)
        
        // Save heightmap and biomes
        //level_tag.put(NBTIntArray(name: "HeightMap", values: chunk.heightmap))
        level_tag.put(NBTByteArray(name: "Biomes", values: chunk.biomes))
        
        // Save slime chunk
        //level_tag.put(NBTByte(name: "isSlimeChunk", value: chunk.slimeChunk ? 1 : 0))
        
        // And write to file
        try? writeChunkBuffer(x: x, z: z, tag: NBTCompound(name: nil, values: [level_tag]))
    }
    
    // Find a new sector
    private func findNewSectorStart(for sectorsNeeded: Int) -> Int32 {
        // Init variables
        var start = -1
        var runLength = 0
        var i = sectorsUsed.firstIndex(where: { $0 == false }) ?? sectorsUsed.count
        
        // Iterate sectors
        while i < sectorsUsed.count {
            // Check if sector is used
            if sectorsUsed[i] {
                // Reset
                start = -1
                runLength = 0
            } else {
                if start == -1 {
                    start = i
                }
                runLength += 1
                if runLength >= sectorsNeeded {
                    return Int32(start)
                }
            }
            
            // Increment i (next sector)
            i += 1
        }
        
        // End of file
        return -1
    }
    
    // Write data to a sector
    private func write(sector: Int32, buffer: inout ByteBuffer) {
        fileHandle.seek(to: UInt64(Int(sector) * WorldRegion.sector_bytes))
        fileHandle.write(Data(from: Int32(buffer.readableBytes + 1)))
        fileHandle.write(Data(from: WorldRegion.version_deflate))
        fileHandle.write(Data(buffer: buffer))
    }

}
