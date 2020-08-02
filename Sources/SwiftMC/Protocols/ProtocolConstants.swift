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

public class ProtocolConstants {
    
    // Version constants
    public static var minecraft_1_8: Int32 = 47
    public static var minecraft_1_9: Int32 = 107
    public static var minecraft_1_9_1: Int32 = 108
    public static var minecraft_1_9_2: Int32 = 109
    public static var minecraft_1_9_4: Int32 = 110
    public static var minecraft_1_10: Int32 = 210
    public static var minecraft_1_11: Int32 = 315
    public static var minecraft_1_12: Int32 = 335
    public static var minecraft_1_12_1: Int32 = 338
    public static var minecraft_1_12_2: Int32 = 340
    public static var minecraft_1_13: Int32 = 393
    public static var minecraft_1_13_1: Int32 = 401
    public static var minecraft_1_13_2: Int32 = 404
    public static var minecraft_1_14: Int32 = 477
    public static var minecraft_1_14_1: Int32 = 480
    public static var minecraft_1_14_2: Int32 = 485
    public static var minecraft_1_14_3: Int32 = 490
    public static var minecraft_1_14_4: Int32 = 498
    public static var minecraft_1_15: Int32 = 573
    public static var minecraft_1_15_1: Int32 = 575
    public static var minecraft_1_15_2: Int32 = 578
    
    public static var supported_versions = [
        "1.8.x",
        "1.9.x",
        "1.10.x",
        "1.11.x",
        "1.12.x",
        "1.13.x",
        "1.14.x",
        "1.15.x"
    ]
    
    public static var supported_versions_ids = [
        minecraft_1_8,
        minecraft_1_9,
        minecraft_1_9_1,
        minecraft_1_9_2,
        minecraft_1_9_4,
        minecraft_1_10,
        minecraft_1_11,
        minecraft_1_12,
        minecraft_1_12_1,
        minecraft_1_12_2,
        minecraft_1_13,
        minecraft_1_13_1,
        minecraft_1_13_2,
        minecraft_1_14,
        minecraft_1_14_1,
        minecraft_1_14_2,
        minecraft_1_14_3,
        minecraft_1_14_4,
        minecraft_1_15,
        minecraft_1_15_1,
        minecraft_1_15_2
    ]
    
}

enum Direction {
    
    case to_client, to_server
    
}
