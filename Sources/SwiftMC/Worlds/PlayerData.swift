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

public class PlayerData {
    
    // Internal storage
    public let uuid: String
    public let world: LocalWorld
    private var root: NBTCompound?
    
    // Variables
    var position: (Double, Double, Double) {
        get {
            let list = (root?["Pos"] as? NBTList)?.values.map({ ($0 as? NBTDouble)?.value })
            return (list?[0] ?? 0, list?[1] ?? 64, list?[2] ?? 0)
        }
        set {
            root?.put(NBTList(name: "Pos", values: [
                NBTDouble(name: nil, value: newValue.0),
                NBTDouble(name: nil, value: newValue.1),
                NBTDouble(name: nil, value: newValue.2)
            ]))
        }
    }
    var rotation: (Float, Float) {
        get {
            let list = (root?["Rotation"] as? NBTList)?.values.map({ ($0 as? NBTFloat)?.value })
            return (list?[0] ?? 0, list?[1] ?? 0)
        }
        set {
            root?.put(NBTList(name: "Rotation", values: [
                NBTFloat(name: nil, value: newValue.0),
                NBTFloat(name: nil, value: newValue.1)
            ]))
        }
    }
    var location: Location {
        get {
            let position = self.position
            let rotation = self.rotation
            return Location(world: world, x: position.0, y: position.1, z: position.2, yaw: rotation.0, pitch: rotation.1)
        }
        set {
            self.position = (newValue.x, newValue.y, newValue.z)
            self.rotation = (newValue.yaw, newValue.pitch)
        }
    }
    var dimension: Int32 {
        get { return (root?["Dimension"] as? NBTInt)?.value ?? 0 }
        set { root?.put(NBTInt(name: "Dimension", value: newValue)) }
    }
    var playerGameType: GameMode {
        get { return (root?["playerGameType"] as? NBTInt)?.value ?? 0 }
        set { root?.put(NBTInt(name: "playerGameType", value: newValue)) }
    }
    
    // Read from file
    public init(for uuid: String, in world: LocalWorld) {
        // Save UUID and world
        self.uuid = uuid
        self.world = world
        
        // Check if the world folder exists
        let folder = world.path.appendingPathComponent("playerdata")
        if !FileManager.default.fileExists(atPath: folder.path) {
            // Create a folder
            try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true, attributes: nil)
        }
        
        // Check if the configuration exists
        let file = folder.appendingPathComponent("\(uuid).dat")
        if FileManager.default.fileExists(atPath: file.path), let content = FileManager.default.contents(atPath: file.path) {
            // Try to load configuration
            var buffer: ByteBuffer? = ByteBufferAllocator().buffer(capacity: content.count)
            buffer?.writeBytes(content)
            buffer = try? buffer?.decompress(with: .gzip)
            self.root = buffer?.readNBT() as? NBTCompound
        }
        
        // If the root is nil, generate a new configuration
        if self.root == nil {
            // Compounds creation
            self.root = NBTCompound(name: "", values: [])
            
            // Fill data
            self.location = world.getSpawnLocation()
            self.playerGameType = world.config.gameType
        }
    }
    
    // Update with a player object
    internal func update(with client: ChannelWrapper) {
        // Fill the player data
        self.location = client.getLocation()
        self.playerGameType = client.gamemode ?? 0
    }
    
    // Save to file
    public func save() throws {
        // Get the content
        guard let root = root else { return }
        
        // Put the content in a buffer
        var player_content = ByteBufferAllocator().buffer(capacity: root.fullSize())
        player_content.writeNBT(tag: root)
        player_content = try player_content.compress(with: .gzip)
        
        // Save to disk
        let file = world.path.appendingPathComponent("playerdata").appendingPathComponent("\(uuid).dat")
        FileManager.default.createFile(atPath: file.path, contents: player_content.readData(length: player_content.readableBytes), attributes: nil)
    }
    
}
