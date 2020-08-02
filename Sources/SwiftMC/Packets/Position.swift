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

public class Position: Packet {
    
    public var x: Double
    public var y: Double
    public var z: Double
    public var yaw: Float
    public var pitch: Float
    public var flags: UInt8
    public var teleportId: Int32
    
    public required init() {
        x = 0
        y = 0
        z = 0
        yaw = 0
        pitch = 0
        flags = 0
        teleportId = 0
    }
    
    public init(x: Double, y: Double, z: Double, yaw: Float = 0, pitch: Float = 0, flags: UInt8 = 0, teleportId: Int32) {
        self.x = x
        self.y = y
        self.z = z
        self.yaw = yaw
        self.pitch = pitch
        self.flags = flags
        self.teleportId = teleportId
    }
    
    public func readPacket(from buffer: inout ByteBuffer, direction: DirectionData, protocolVersion: Int32) {
        x = buffer.readDouble() ?? x
        y = buffer.readDouble() ?? y
        z = buffer.readDouble() ?? z
        yaw = buffer.readFloat() ?? yaw
        pitch = buffer.readFloat() ?? pitch
        flags = buffer.readBytes(length: 1)?.first ?? flags
        if protocolVersion >= ProtocolConstants.minecraft_1_9 {
            teleportId = buffer.readVarInt() ?? teleportId
        }
    }
    
    public func writePacket(to buffer: inout ByteBuffer, direction: DirectionData, protocolVersion: Int32) {
        buffer.writeDouble(value: x)
        buffer.writeDouble(value: y)
        buffer.writeDouble(value: z)
        buffer.writeFloat(value: yaw)
        buffer.writeFloat(value: pitch)
        buffer.writeBytes([flags])
        if protocolVersion >= ProtocolConstants.minecraft_1_9 {
            buffer.writeVarInt(value: teleportId)
        }
    }
    
    public func toString() -> String {
        return "Position(x: \(x), y: \(y), z: \(z), yaw: \(yaw), pitch: \(pitch), teleportId: \(teleportId))"
    }
    
}
