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

public class EncryptionResponse: Packet {
    
    public var sharedSecret: [UInt8]
    public var verifyToken: [UInt8]
    
    public required init() {
        sharedSecret = []
        verifyToken = []
    }
    
    public init(sharedSecret: [UInt8], verifyToken: [UInt8]) {
        self.sharedSecret = sharedSecret
        self.verifyToken = verifyToken
    }
    
    public func readPacket(from buffer: inout ByteBuffer, direction: DirectionData, protocolVersion: Int32) {
        sharedSecret = buffer.readArray() ?? sharedSecret
        verifyToken = buffer.readArray() ?? verifyToken
    }
    
    public func writePacket(to buffer: inout ByteBuffer, direction: DirectionData, protocolVersion: Int32) {
        buffer.writeArray(value: sharedSecret)
        buffer.writeArray(value: verifyToken)
    }
    
    public func toString() -> String {
        return "EncryptionResponse(sharedSecret: \(sharedSecret), verifyToken: \(verifyToken))"
    }
    
}
