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

public class DirectionData {
    
    // Variables
    var prot: Prot
    var direction: Direction
    var protocols = [Int32: ProtocolData]()
    
    init(prot: Prot, direction: Direction) {
        // Save properties
        self.prot = prot
        self.direction = direction
        
        // And init protocols data
        for current in ProtocolConstants.supported_versions_ids {
            protocols[current] = ProtocolData(protocolVersion: current)
        }
    }
    
    // Get protocol data
    func getProtocolData(version: Int32) -> ProtocolData? {
        if let current = protocols[version] {
            return current
        } else if let first = protocols.values.first, prot.name != "GAME" {
            return first
        }
        return nil
    }
    
    // Register a packet
    func registerPacket(packetClass: Packet.Type, mappings: [ProtocolMapping]) {
        var mappingIndex = 0
        var mapping = mappings[0]
        for current in ProtocolConstants.supported_versions_ids {
            // Checks
            if current < mapping.protocolVersion {
                // New packet, skip till reach next protocol
                continue
            }
            if mapping.protocolVersion < current && mappingIndex + 1 < mappings.count {
                // Go to next
                let nextMapping = mappings[mappingIndex + 1]
                if nextMapping.protocolVersion == current {
                    if nextMapping.packetID != mapping.packetID {
                        mapping = nextMapping
                        mappingIndex += 1
                    }
                }
            }
            
            // Save
            let data = protocols[current]
            data?.packetMap[mapping.packetID] = packetClass
        }
    }
    
    // Create a packet from id
    func createPacket(id: Int32, version: Int32) -> Packet {
        if let protocolData = getProtocolData(version: version), id <= Prot.max_packet_id, let packet = protocolData.packetMap[id]?.init() {
            return packet
        }
        return UnknownPacket()
    }
    
    // Get id from a packet
    func getId(for packet: Packet.Type, version: Int32) -> Int32? {
        guard let protocolData = getProtocolData(version: version) else {
            return nil
        }
        return protocolData.packetMap.first { item in
            return item.value == packet
        }?.key
    }
    
}
