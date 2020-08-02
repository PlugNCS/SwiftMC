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

public struct ServerInfo: Codable {
    
    // MARK: - JSON Encoding/Decoding
    
    public static func decode(from json: String) -> ServerInfo? {
        if let data = json.data(using: .utf8), let object = try? JSONDecoder().decode(ServerInfo.self, from: data) {
            return object
        }
        return nil
    }
    
    public func toJSON() -> String? {
        if let json = try? JSONEncoder().encode(self), let string = String(bytes: json, encoding: .utf8) {
            return string
        }
        return nil
    }
    
    // MARK: - Server info content
    
    public var version: ServerVersion?
    public var players: ServerPlayers?
    public var description: ChatMessage?
    public var favicon: String?
    
    // MARK: - Server version
    
    public struct ServerVersion: Codable {
        enum CodingKeys: String, CodingKey {
            case name = "name", protocolVersion = "protocol"
        }
        var name: String?
        var protocolVersion: Int32?
    }
    
    // MARK: - Player list
    
    public struct ServerPlayers: Codable {
        var max: Int?
        var online: Int?
        var sample: [ServerPlayer]?
    }
    
    public struct ServerPlayer: Codable {
        var name: String?
        var id: String?
    }
    
}
