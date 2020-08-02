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

public class ChatMessage: Codable {
    
    // MARK: - JSON Encoding/Decoding
    
    static func decode(from json: String) -> ChatMessage? {
        if let data = json.data(using: .utf8), let object = try? JSONDecoder().decode(ChatMessage.self, from: data) {
            return object
        }
        return nil
    }
    
    func toJSON() -> String? {
        if let json = try? JSONEncoder().encode(self), let string = String(bytes: json, encoding: .utf8) {
            return string
        }
        return nil
    }
    
    // MARK: - Chat message content
    
    private var text: String
    private var extra: [ChatMessage]?
    private var parent: ChatMessage?
    private var color: String?
    private var bold: Bool?
    private var italic: Bool?
    private var underlined: Bool?
    private var strikethrough: Bool?
    private var obfuscated: Bool?
    
    enum CodingKeys: String, CodingKey {
        case text, extra, color, bold, italic, underlined, strikethrough, obfuscated
    }
    
    public init() {
        self.text = ""
    }
    
    public init(text: String) {
        // Init extras and some other properties
        self.text = ""
        var builder = ""
        var component = ChatMessage()
        var i = 0
        
        // Iterate text to create extra if needed
        while i < text.count {
            var char = text[text.index(text.startIndex, offsetBy: i)]
            if char == ChatColor.color_char {
                i += 1
                if i >= text.count {
                    break
                }
                char = text[text.index(text.startIndex, offsetBy: i)]
                if ("ABCDEFGHIJKLMNOPQRSTUVWXYZ").contains(char) {
                    char = char.lowercased().first!
                }
                guard let format = ChatColor.all.first(where: { $0.char == char }) else {
                    i += 1
                    continue
                }
                if !builder.isEmpty {
                    let old = component
                    component = ChatMessage(from: old)
                    old.text = builder
                    builder = ""
                    add(extra: old)
                }
                component = component.with(format: format)
                i += 1
                continue
            }
            builder.append(char)
            i += 1
        }
        component.text = builder
        
        // Check component count
        if let extra = extra, !extra.isEmpty {
            // Add what left
            add(extra: component)
        } else {
            // Set left text
            copyFormatting(from: component)
            self.text = component.text
        }
    }
    
    public init(from component: ChatMessage) {
        self.text = component.text
        copyFormatting(from: component)
        if let extra = extra {
            for e in extra {
                add(extra: e.duplicate())
            }
        }
    }
    
    public init(extra: [ChatMessage]) {
        // Just init from extras
        self.text = ""
        self.extra = extra
        self.extra?.forEach { message in
            message.parent = self
        }
    }
    
    public func with(format: ChatColor) -> ChatMessage {
        if ChatColor.colors.contains(where: { $0.id == format.id }) {
            self.color = format.id
        }
        if format.id == ChatColor.bold.id {
            self.bold = true
        }
        if format.id == ChatColor.italic.id {
            self.italic = true
        }
        if format.id == ChatColor.underline.id {
            self.underlined = true
        }
        if format.id == ChatColor.strikethrough.id {
            self.strikethrough = true
        }
        if format.id == ChatColor.magic.id {
            self.obfuscated = true
        }
        if format.id == ChatColor.reset.id {
            self.color = ChatColor.white.id
        }
        return self
    }
    
    public func add(extra: ChatMessage) {
        if self.extra == nil {
            self.extra = []
        }
        extra.parent = self
        self.extra?.append(extra)
    }
    
    public func getExtra() -> [ChatMessage]? {
        return extra ?? []
    }
    
    public func getText() -> String {
        return text
    }
    
    public func duplicate() -> ChatMessage {
        return ChatMessage(from: self)
    }
    
    public func copyFormatting(from component: ChatMessage, replace: Bool = true) {
        // Events
        // TODO
        
        // Formatting
        if replace || color == nil {
            color = component.color
        }
        if replace || bold == nil {
            bold = component.bold
        }
        if replace || italic == nil {
            italic = component.italic
        }
        if replace || underlined == nil {
            underlined = component.underlined
        }
        if replace || strikethrough == nil {
            strikethrough = component.strikethrough
        }
        if replace || obfuscated == nil {
            obfuscated = component.obfuscated
        }
    }
    
    public func getColor() -> ChatColor {
        for color in ChatColor.colors {
            if self.color == color.id {
                return color
            }
        }
        return parent?.getColor() ?? .white
    }
    
    public func toString(useAnsi: Bool = false) -> String {
        // Init string
        var string = ""
        
        // Add format
        string += useAnsi ? getColor().toAnsi() : getColor().description
        
        // Read extra
        if let extra = extra, !extra.isEmpty {
            // Add extras
            string += extra.map { $0.toString(useAnsi: useAnsi) }.joined()
        } else {
            // Just add the text
            string += text
        }
        
        // Return the final result
        return string
    }
    
}
