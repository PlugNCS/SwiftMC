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

public class WorldChunkData {
    
    private let maxHeight: Int32
    private var sections: [[UInt16]]

    public init(world: LocalWorld) {
        self.maxHeight = 128 // TODO: Make a parameter to change this value
        self.sections = [[UInt16]](repeating: [], count: WorldChunk.section_count)
    }
    
    public func index(x: Int32, y: Int32, z: Int32) -> Int {
        return Int((y & 0xF) << 8 | z << 4 | x)
    }

    public func getData(x: Int32, y: Int32, z: Int32) -> UInt8 {
        if x < 0 || y < 0 || z < 0 || x >= WorldChunk.height || y >= WorldChunk.depth || z >= WorldChunk.width {
            return 0
        }
        if sections[Int(y >> 4)].isEmpty {
            return 0
        }
        return UInt8(sections[Int(y >> 4)][index(x: x, y: y, z: z)] & 0xF)
    }

    public func getType(x: Int32, y: Int32, z: Int32) -> Material? {
        return Material.get(id: UInt16(getTypeId(x: x, y: y, z: z)))
    }

    public func getTypeAndData(x: Int32, y: Int32, z: Int32) -> MaterialData? {
        return getType(x: x, y: y, z: z)?.getNewData(raw: getData(x: x, y: y, z: z))
    }

    public func getTypeId(x: Int32, y: Int32, z: Int32) -> UInt8 {
        if x < 0 || y < 0 || z < 0 || x >= WorldChunk.height || y >= WorldChunk.depth || z >= WorldChunk.width {
            return 0
        }
        if sections[Int(y >> 4)].isEmpty {
            return 0
        }
        return UInt8(sections[Int(y >> 4)][index(x: x, y: y, z: z)] >> 4)
    }

    public func setBlock(x: Int32, y: Int32, z: Int32, material: Material) {
        if material.isBlock() {
            setBlock(x: x, y: y, z: z, blockId: UInt8(material.id))
        }
    }

    public func setBlock(x: Int32, y: Int32, z: Int32, materialData: MaterialData) {
        if materialData.id < 256 {
            setBlock(x: x, y: y, z: z, blockId: UInt8(materialData.id), data: materialData.data)
        }
    }

    public func setBlock(x: Int32, y: Int32, z: Int32, blockId: UInt8, data: UInt8 = 0) {
        if x < 0 || y < 0 || z < 0 || x >= WorldChunk.height || y >= WorldChunk.depth || z >= WorldChunk.width {
            return
        }
        if sections[Int(y >> 4)].isEmpty {
            sections[Int(y >> 4)] = [UInt16](repeating: 0, count: 4096)
        }
        sections[Int(y >> 4)][index(x: x, y: y, z: z)] = (UInt16(blockId) << 4) | UInt16(data)
    }
    
    internal func getSections() -> [[UInt16]] {
        return sections
    }
    
}
