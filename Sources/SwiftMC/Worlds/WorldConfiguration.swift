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

public class WorldConfiguration {
    
    // Internal storage
    private var root: NBTCompound?
    private var data: NBTCompound? {
        return root?["Data"] as? NBTCompound
    }
    
    // Variables
    var difficulty: Int8 {
        get { return (data?["Difficulty"] as? NBTByte)?.value ?? 2 }
        set { data?.put(NBTByte(name: "Difficulty", value: newValue)) }
    }
    var dayTime: Int64 {
        get { return (data?["DayTime"] as? NBTLong)?.value ?? 0 }
        set { data?.put(NBTLong(name: "DayTime", value: newValue)) }
    }
    var gameType: GameMode {
        get { return (data?["GameType"] as? NBTInt)?.value ?? 0 }
        set { data?.put(NBTInt(name: "GameType", value: newValue)) }
    }
    var initialized: Bool {
        get { return (data?["initialized"] as? NBTByte)?.value == 1 }
        set { data?.put(NBTByte(name: "initialized", value: newValue ? 1 : 0)) }
    }
    var levelName: String {
        get { return (data?["LevelName"] as? NBTString)?.value ?? "" }
        set { data?.put(NBTString(name: "LevelName", value: newValue)) }
    }
    var randomSeed: Int64 {
        get { return (data?["RandomSeed"] as? NBTLong)?.value ?? 0 }
        set { data?.put(NBTLong(name: "RandomSeed", value: newValue)) }
    }
    var spawnX: Int32 {
        get { return (data?["SpawnX"] as? NBTInt)?.value ?? 0 }
        set { data?.put(NBTInt(name: "SpawnX", value: newValue)) }
    }
    var spawnY: Int32 {
        get { return (data?["SpawnY"] as? NBTInt)?.value ?? 64 }
        set { data?.put(NBTInt(name: "SpawnY", value: newValue)) }
    }
    var spawnZ: Int32 {
        get { return (data?["SpawnZ"] as? NBTInt)?.value ?? 0 }
        set { data?.put(NBTInt(name: "SpawnZ", value: newValue)) }
    }
    
    // Read from file
    public func read(from file: URL) throws {
        // Check if the configuration exists
        if FileManager.default.fileExists(atPath: file.path), let content = FileManager.default.contents(atPath: file.path) {
            // Try to load configuration
            var buffer = ByteBufferAllocator().buffer(capacity: content.count)
            buffer.writeBytes(content)
            buffer = try buffer.decompress(with: .gzip)
            self.root = buffer.readNBT() as? NBTCompound
        }
        
        // If the root is nil, generate a new configuration
        if self.root == nil {
            // Compounds creation
            self.root = NBTCompound(name: "", values: [NBTCompound(name: "Data")])
            
            // Fill data
            self.difficulty = 2
            self.dayTime = 0
            self.gameType = 0
            self.initialized = false
            self.levelName = file.lastPathComponent
            self.randomSeed = Int64.random(in: Int64.min ... Int64.max)
        }
    }
    
    // Save to file
    public func save(to file: URL) throws {
        // Get the content
        guard let root = root else { return }
        
        // Put the content in a buffer
        var level_content = ByteBufferAllocator().buffer(capacity: root.fullSize())
        level_content.writeNBT(tag: root)
        level_content = try level_content.compress(with: .gzip)
        
        // Save to disk
        FileManager.default.createFile(atPath: file.path, contents: level_content.readData(length: level_content.readableBytes), attributes: nil)
    }
    
}
