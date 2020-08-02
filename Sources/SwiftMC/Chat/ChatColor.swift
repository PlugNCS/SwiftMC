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

public class ChatColor: CustomStringConvertible, Equatable {
    
    public static let black = ChatColor("0", id: "black", ansi: 30)
    public static let dark_blue = ChatColor("1", id: "dark_blue", ansi: 34)
    public static let dark_green = ChatColor("2", id: "dark_green", ansi: 32)
    public static let dark_aqua = ChatColor("3", id: "dark_aqua", ansi: 36)
    public static let dark_red = ChatColor("4", id: "dark_red", ansi: 31)
    public static let dark_purple = ChatColor("5", id: "dark_purple", ansi: 35)
    public static let gold = ChatColor("6", id: "gold", ansi: 33)
    public static let gray = ChatColor("7", id: "gray", ansi: 37)
    public static let dark_gray = ChatColor("8", id: "dark_gray", ansi: 90)
    public static let blue = ChatColor("9", id: "blue", ansi: 94)
    public static let green = ChatColor("a", id: "green", ansi: 92)
    public static let aqua = ChatColor("b", id: "aqua", ansi: 96)
    public static let red = ChatColor("c", id: "red", ansi: 91)
    public static let light_purple = ChatColor("d", id: "light_purple", ansi: 95)
    public static let yellow = ChatColor("e", id: "yellow", ansi: 93)
    public static let white = ChatColor("f", id: "white", ansi: 97)
    public static let magic = ChatColor("k", id: "obfuscated", ansi: 5)
    public static let bold = ChatColor("l", id: "bold", ansi: 1)
    public static let strikethrough = ChatColor("m", id: "strikethrough", ansi: 9)
    public static let underline = ChatColor("n", id: "underline", ansi: 4)
    public static let italic = ChatColor("o", id: "italic", ansi: 3)
    public static let reset = ChatColor("r", id: "reset", ansi: 0)
    
    public static let colors: [ChatColor] = [
        .black, .dark_blue, .dark_green, .dark_aqua, .dark_red, .dark_purple, .gold, .gray,
        .dark_gray, .blue, .green, .aqua, .red, .light_purple, .yellow, .white, .reset
    ]
    
    public static let all: [ChatColor] = colors + [
        .magic, .bold, .strikethrough, .underline, .italic, .reset
    ]
    
    public static let color_char: Character = "§"
    
    public static func + (lhs: ChatColor, rhs: ChatColor) -> String {
        return lhs.description + rhs.description
    }
    
    public let char: Character
    public let id: String
    public let ansi: Int
    
    internal init(_ char: Character, id: String, ansi: Int) {
        self.char = char
        self.id = id
        self.ansi = ansi
    }
    
    public var description: String {
        return "\(ChatColor.color_char)\(char)"
    }
    
    public func toAnsi() -> String {
        return "\u{001B}[\(ansi)m"
    }
    
    public static func == (lhs: ChatColor, rhs: ChatColor) -> Bool {
        return lhs.id == rhs.id
    }
    
}
