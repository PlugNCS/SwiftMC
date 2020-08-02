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

public class Configuration {
    
    public let protocolVersion: Int32
    public let port: Int
    public let slots: Int
    public let viewDistance: Int32
    public let mode: AuthentificationMode
    public let motd: String
    public let localWorlds: [[String: Any]]
    public let remoteWorlds: [[String: Any]]
    public let bstats: [String: Any]
    public let debug: Bool
    public let favicon: String? = nil
    
    internal init(serverRoot: URL) {
        // Check if the server folder exists
        if !FileManager.default.fileExists(atPath: serverRoot.path) {
            // Create a folder
            try? FileManager.default.createDirectory(at: serverRoot, withIntermediateDirectories: true, attributes: nil)
        }
        
        // Get the content of the configuration file if exists
        let file = serverRoot.appendingPathComponent("swiftmc.json")
        var content = (try? JSONSerialization.jsonObject(with: FileManager.default.contents(atPath: file.path) ?? Data(), options: []) as? [String: Any]) ?? [:]
        
        // Protocol version
        if let protocolVersion = content["protocol-version"] as? Int {
            self.protocolVersion = Int32(protocolVersion)
        } else {
            self.protocolVersion = ProtocolConstants.supported_versions_ids.last ?? 0
            content["protocol-version"] = Int(protocolVersion)
        }
        
        // Port
        if let port = content["port"] as? Int {
            self.port = port
        } else {
            self.port = 25565
            content["port"] = port
        }
        
        // Slots
        if let slots = content["slots"] as? Int {
            self.slots = slots
        } else {
            self.slots = 42
            content["slots"] = slots
        }
        
        // View distance
        if let viewDistance = content["view-distance"] as? Int {
            self.viewDistance = Int32(viewDistance)
        } else {
            self.viewDistance = 16
            content["view-distance"] = Int(viewDistance)
        }
        
        // Authentification mode
        if let mode = content["authentification-mode"] as? String {
            self.mode = mode == "offline" ? .offline : mode == "auto" ? .auto : .online
        } else {
            self.mode = .online
            content["authentification-mode"] = mode == .offline ? "offline" : mode == .auto ? "auto" : "online"
        }
        
        // MOTD
        if let motd = content["motd"] as? String {
            self.motd = motd
        } else {
            self.motd = "A SwiftMC Server"
            content["motd"] = motd
        }
        
        // bStats
        if let bstats = content["bstats"] as? [String: Any] {
            self.bstats = bstats
        } else {
            self.bstats = ["enabled": true, "server-uuid": UUID().uuidString.lowercased()]
            content["bstats"] = bstats
        }
        
        // Debug
        if let debug = content["enable-debug"] as? Bool {
            self.debug = debug
        } else {
            self.debug = false
            content["enable-debug"] = debug
        }
        
        // Local worlds
        if let localWorlds = content["local-worlds"] as? [[String: Any]] {
            self.localWorlds = localWorlds
        } else {
            self.localWorlds = [["name": "world", "generator": "overworld"]]
            content["local-worlds"] = localWorlds
        }
        
        // Remote worlds
        if let remoteWorlds = content["remote-worlds"] as? [[String: Any]] {
            self.remoteWorlds = remoteWorlds
        } else {
            self.remoteWorlds = []
            content["remote-worlds"] = remoteWorlds
        }
        
        // Save modifications
        if let json = try? JSONSerialization.data(withJSONObject: content, options: .prettyPrinted) {
            FileManager.default.createFile(atPath: file.path, contents: json, attributes: nil)
        }
    }
    
}
