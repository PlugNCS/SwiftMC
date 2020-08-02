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

public class PlayerLook: Packet {
    
    public var yaw: Float
    public var pitch: Float
    public var onGround: Bool
    
    public required init() {
        yaw = 0
        pitch = 0
        onGround = true
    }
    
    public init(yaw: Float = 0, pitch: Float = 0, onGround: Bool = true) {
        self.yaw = yaw
        self.pitch = pitch
        self.onGround = onGround
    }
    
    public func readPacket(from buffer: inout ByteBuffer, direction: DirectionData, protocolVersion: Int32) {
        yaw = buffer.readFloat() ?? yaw
        pitch = buffer.readFloat() ?? pitch
        onGround = buffer.readBool() ?? onGround
    }
    
    public func writePacket(to buffer: inout ByteBuffer, direction: DirectionData, protocolVersion: Int32) {
        buffer.writeFloat(value: yaw)
        buffer.writeFloat(value: pitch)
        buffer.writeBool(value: onGround)
    }
    
    public func toString() -> String {
        return "PlayerLook(yaw: \(yaw), pitch: \(pitch), onGround: \(onGround))"
    }
    
}
