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

public class HelpCommand: Command {
    
    public func execute(server: SwiftMC, sender: CommandSender, args: [String]) {
        // Init base message
        var message = ChatColor.aqua + "SwiftMC Server - Developed by Nathan Fallet at Groupe MINASTE"
        
        // Iterate commands
        for (name, command) in server.commands {
            message.append("\n\(ChatColor.gold)/\(name): \(ChatColor.yellow)\(command.description())")
        }
        
        // Print help
        sender.sendMessage(message: ChatMessage(text: message))
    }
    
    public func description() -> String {
        return "Print this help command"
    }
    
}
