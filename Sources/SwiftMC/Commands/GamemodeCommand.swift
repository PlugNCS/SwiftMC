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

public class GamemodeCommand: Command {
    
    public func execute(server: SwiftMC, sender: CommandSender, args: [String]) {
        // Check sender
        if let player = sender as? Player {
            if args.count == 1 || args.count == 2 {
                // Get gamemode
                var gamemode: GameMode?
                if args[0] == "survival" || args[0] == "0" {
                    gamemode = .survival
                } else if args[0] == "creative" || args[0] == "1" {
                    gamemode = .creative
                } else if args[0] == "adventure" || args[0] == "2" {
                    gamemode = .adventure
                } else if args[0] == "spectator" || args[0] == "3" {
                    gamemode = .spectator
                }
                
                // Check gamemode
                if let gamemode = gamemode {
                    // Check player
                    var target = player
                    if args.count == 2 {
                        guard let newTarget = server.getPlayer(name: args[1]) else {
                            // Error message
                            sender.sendMessage(message: ChatColor.red + "Unable to find player \(args[1])!")
                            return
                        }
                        target = newTarget
                    }
                    
                    // Change gamemode
                    target.setGameMode(to: gamemode)
                    sender.sendMessage(message: ChatColor.yellow + "\(target.getName() == player.getName() ? "Your" : player.getName()+"'s") gamemode was changed to \(gamemode)!")
                } else {
                    // Error message
                    sender.sendMessage(message: ChatColor.red + "Usage: /gamemode <survival/creative/adventure/spectator/0/1/2/3> [player]")
                }
            } else {
                // Error message
                sender.sendMessage(message: ChatColor.red + "Usage: /gamemode <survival/creative/adventure/spectator/0/1/2/3> [player]")
            }
        } else {
            // Error message
            sender.sendMessage(message: ChatColor.red + "Only players can use this command!")
        }
    }
    
    public func description() -> String {
        return "Change a player gamemode"
    }
    
}
