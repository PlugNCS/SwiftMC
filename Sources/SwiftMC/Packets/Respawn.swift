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

public class Respawn: Packet {
    
    public var dimension: Int32
    public var hashedSeed: Int64
    public var difficulty: UInt8
    public var gameMode: UInt8
    public var levelType: String
    
    public required init() {
        dimension = 0
        hashedSeed = 0
        difficulty = 0
        gameMode = 0
        levelType = ""
    }
    
    public init(dimension: Int32, hashedSeed: Int64, difficulty: UInt8, gameMode: UInt8, levelType: String) {
        self.dimension = dimension
        self.hashedSeed = hashedSeed
        self.difficulty = difficulty
        self.gameMode = gameMode
        self.levelType = levelType
    }
    
    public func readPacket(from buffer: inout ByteBuffer, direction: DirectionData, protocolVersion: Int32) {
        dimension = buffer.readInteger(as: Int32.self) ?? dimension
        if protocolVersion >= ProtocolConstants.minecraft_1_15 {
            hashedSeed = buffer.readInteger(as: Int64.self) ?? hashedSeed
        }
        if protocolVersion < ProtocolConstants.minecraft_1_14 {
            difficulty = buffer.readBytes(length: 1)?.first ?? difficulty
        }
        gameMode = buffer.readBytes(length: 1)?.first ?? gameMode
        levelType = buffer.readVarString() ?? levelType
    }
    
    public func writePacket(to buffer: inout ByteBuffer, direction: DirectionData, protocolVersion: Int32) {
        buffer.writeInteger(dimension)
        if protocolVersion >= ProtocolConstants.minecraft_1_15 {
            buffer.writeInteger(hashedSeed)
        }
        if protocolVersion < ProtocolConstants.minecraft_1_14 {
            buffer.writeBytes([difficulty])
        }
        buffer.writeBytes([gameMode])
        buffer.writeVarString(string: levelType)
    }
    
    public func toString() -> String {
        return "Respawn(dimension: \(dimension), hashedSeed: \(hashedSeed), difficulty: \(difficulty), gameMode: \(gameMode), levelType: \(levelType))"
    }
    
}
