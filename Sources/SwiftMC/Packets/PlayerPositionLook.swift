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

public class PlayerPositionLook: Packet {
    
    public var x: Double
    public var y: Double
    public var z: Double
    public var yaw: Float
    public var pitch: Float
    public var onGround: Bool
    
    public required init() {
        x = 0
        y = 0
        z = 0
        yaw = 0
        pitch = 0
        onGround = true
    }
    
    public init(x: Double, y: Double, z: Double, yaw: Float = 0, pitch: Float = 0, onGround: Bool = true) {
        self.x = x
        self.y = y
        self.z = z
        self.yaw = yaw
        self.pitch = pitch
        self.onGround = onGround
    }
    
    public func readPacket(from buffer: inout ByteBuffer, direction: DirectionData, protocolVersion: Int32) {
        x = buffer.readDouble() ?? x
        y = buffer.readDouble() ?? y
        z = buffer.readDouble() ?? z
        yaw = buffer.readFloat() ?? yaw
        pitch = buffer.readFloat() ?? pitch
        onGround = buffer.readBool() ?? onGround
    }
    
    public func writePacket(to buffer: inout ByteBuffer, direction: DirectionData, protocolVersion: Int32) {
        buffer.writeDouble(value: x)
        buffer.writeDouble(value: y)
        buffer.writeDouble(value: z)
        buffer.writeFloat(value: yaw)
        buffer.writeFloat(value: pitch)
        buffer.writeBool(value: onGround)
    }
    
    public func toString() -> String {
        return "PlayerPositionLook(x: \(x), y: \(y), z: \(z), yaw: \(yaw), pitch: \(pitch), onGround: \(onGround))"
    }
    
}
