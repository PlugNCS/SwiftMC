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

public class MapChunk: Packet {
    
    public var x: Int32
    public var z: Int32
    public var groundUp: Bool
    public var bitMap: Int32
    public var heightmaps: NBTTag
    public var biomes: [Int32]
    public var chunkData: [UInt8]
    public var blockEntities: [NBTTag]
    
    public required init() {
        x = 0
        z = 0
        groundUp = false
        bitMap = 0
        heightmaps = NBTCompound(name: "")
        biomes = []
        chunkData = []
        blockEntities = []
    }
    
    public init(x: Int32, z: Int32, groundUp: Bool, bitMap: Int32, heightmaps: NBTCompound, biomes: [Int32], chunkData: [UInt8], blockEntities: [NBTTag]) {
        self.x = x
        self.z = z
        self.groundUp = groundUp
        self.bitMap = bitMap
        self.heightmaps = heightmaps
        self.biomes = biomes
        self.chunkData = chunkData
        self.blockEntities = blockEntities
    }
    
    public func readPacket(from buffer: inout ByteBuffer, direction: DirectionData, protocolVersion: Int32) {
        self.x = buffer.readInteger(as: Int32.self) ?? x
        self.z = buffer.readInteger(as: Int32.self) ?? z
        self.groundUp = buffer.readBool() ?? groundUp
        if protocolVersion >= ProtocolConstants.minecraft_1_9 {
            self.bitMap = buffer.readVarInt() ?? bitMap
        } else {
            self.bitMap = Int32(buffer.readInteger(as: UInt16.self) ?? 0)
        }
        if protocolVersion >= ProtocolConstants.minecraft_1_14 {
            self.heightmaps = buffer.readNBT()
        }
        if protocolVersion >= ProtocolConstants.minecraft_1_15 && groundUp {
            for _ in 0 ..< 1024 {
                self.biomes.append(buffer.readInteger(as: Int32.self) ?? 0)
            }
        }
        self.chunkData = buffer.readBytes(length: Int(buffer.readVarInt() ?? 0)) ?? chunkData
        if protocolVersion >= ProtocolConstants.minecraft_1_9_4 {
            let count = Int(buffer.readVarInt() ?? 0)
            for _ in 0 ..< count {
                blockEntities.append(buffer.readNBT())
            }
        }
    }
    
    public func writePacket(to buffer: inout ByteBuffer, direction: DirectionData, protocolVersion: Int32) {
        buffer.writeInteger(x)
        buffer.writeInteger(z)
        buffer.writeBool(value: groundUp)
        if protocolVersion >= ProtocolConstants.minecraft_1_9 {
            buffer.writeVarInt(value: bitMap)
        } else {
            buffer.writeInteger(UInt16(bitMap), as: UInt16.self)
        }
        if protocolVersion >= ProtocolConstants.minecraft_1_14 {
            buffer.writeNBT(tag: heightmaps)
        }
        if protocolVersion >= ProtocolConstants.minecraft_1_15 && groundUp {
            for i in 0 ..< 1024 {
                if biomes.count > i {
                    buffer.writeInteger(biomes[i], as: Int32.self)
                } else {
                    buffer.writeInteger(127, as: Int32.self)
                }
            }
        }
        buffer.writeVarInt(value: Int32(chunkData.count))
        buffer.writeBytes(chunkData)
        if protocolVersion >= ProtocolConstants.minecraft_1_9_4 {
            buffer.writeVarInt(value: Int32(blockEntities.count))
            for blockEntity in blockEntities {
                buffer.writeNBT(tag: blockEntity)
            }
        }
    }
    
    public func toString() -> String {
        return "MapChunk()"
    }
    
}
