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

public class Material: Equatable {
    
    // Constants
    public static let air = Material(id: 0, stack: 0, transparent: true)
    public static let stone = Material(id: 1, solid: true, occluding: true)
    public static let grass = Material(id: 2, solid: true, occluding: true)
    public static let dirt = Material(id: 3, solid: true, occluding: true)
    public static let cobblestone = Material(id: 4, solid: true, occluding: true)
    public static let wood = Material(id: 5, solid: true, flammable: true, burnable: true, occluding: true)
    public static let sapling = Material(id: 6, transparent: true)
    public static let bedrock = Material(id: 7, solid: true, occluding: true)
    
    // List of all values
    public static let values = [
        air,
        stone,
        grass,
        dirt,
        cobblestone,
        wood,
        sapling,
        bedrock
    ]
    
    // Get a material by id
    public static func get(id: UInt16) -> Material? {
        return values.first(where: { $0.id == id })
    }
    
    // Properties
    public let id: UInt16
    public let stack: UInt8
    public let durability: UInt16
    public let data: MaterialData.Type
    public let edible: Bool
    public let solid: Bool
    public let transparent: Bool
    public let flammable: Bool
    public let burnable: Bool
    public let occluding: Bool
    public let gravity: Bool
    
    // Initializer
    internal init(id: UInt16, stack: UInt8 = 64, durability: UInt16 = 0, data: MaterialData.Type = MaterialData.self, edible: Bool = false, solid: Bool = false, transparent: Bool = false, flammable: Bool = false, burnable: Bool = false, occluding: Bool = false, gravity: Bool = false) {
        self.id = id
        self.stack = stack
        self.durability = durability
        self.data = data
        self.edible = edible
        self.solid = solid
        self.transparent = transparent
        self.flammable = flammable
        self.burnable = burnable
        self.occluding = occluding
        self.gravity = gravity
    }
    
    // Equatable
    public static func == (lhs: Material, rhs: Material) -> Bool {
        return lhs.id == rhs.id
    }
    
    // Create a data object
    public func getNewData(raw: UInt8) -> MaterialData {
        return data.init(id: id, data: raw)
    }
    
    // Checks if material is a block
    public func isBlock() -> Bool {
        return id < 256
    }
    
}
