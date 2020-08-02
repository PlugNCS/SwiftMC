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

public struct Location {
    
    // Variables
    public var world: WorldProtocol
    public var x: Double
    public var y: Double
    public var z: Double
    public var yaw: Float
    public var pitch: Float
    
    // Computed properties
    public var blockX: Int32 { return Int32(x) }
    public var blockY: Int32 { return Int32(y) }
    public var blockZ: Int32 { return Int32(z) }
    
    // Get chunk for this location
    public func getChunk() -> WorldChunk {
        return world.getChunk(x: Int32(Int64(x) >> 4), z: Int32(Int64(z) >> 4))
    }
    
    // Convert to position packet
    public func toPositionServerPacket() -> Position {
        return Position(x: x, y: y, z: z, yaw: yaw, pitch: pitch, flags: 0, teleportId: 0)
    }
    
}
