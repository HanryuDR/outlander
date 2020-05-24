//
//  AliasCommandHandler.swift
//  Outlander
//
//  Created by Eitan Romanoff on 5/24/20.
//  Copyright © 2020 Joe McBride. All rights reserved.
//

import Foundation


class AliasCommandHandler : ICommandHandler {

    var command = "#alias"
    let aliasAddRegex = try? Regex("add \\{(.*?)\\} \\{(.*?)\\}(?:\\s\\{(.*?)\\})?", options: [.caseInsensitive])

    let validCommands = ["add", "load", "reload", "list", "save"]

    func handle(_ command: String, with context: GameContext) {
        let commandStripped = command[6...].trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
        let commandTokens = commandStripped.components(separatedBy: " ")

        if commandTokens.count >= 1 && validCommands.contains(commandTokens[0].lowercased()) {
            switch commandTokens[0].lowercased() {
            case "add":
                if aliasAddRegex?.hasMatches(commandStripped) ?? false {
                    var aliasStr = "\(self.command) \(commandStripped[6...])"
                    AliasLoader(LocalFileSystem(context.applicationSettings)).addFromStr(context.applicationSettings, context: context, aliasStr: &aliasStr)
                    context.events.echoText("Alias added")
                }
                else {
                    context.events.echoText("Invalid syntax. Usage: #alias add {pattern} {replace} {class}")
                }
                return
                
            case "clear":
                context.aliases = []
                context.events.echoText("Aliases cleared")
                return

            case "load", "reload":
                AliasLoader(LocalFileSystem(context.applicationSettings)).load(context.applicationSettings, context: context)
                context.events.echoText("Aliases reloaded")
                return

            case "list":
                context.events.echoText("")

                if context.aliases.isEmpty {
                    context.events.echoText("There are no aliases saved.")
                }

                context.events.echoText("Aliases:")
                for alias in context.aliases {
                    context.events.echoText(String(describing: alias))
                }
                context.events.echoText("")
                return

            case "save":
                AliasLoader(LocalFileSystem(context.applicationSettings)).save(context.applicationSettings, aliases: context.aliases)
                context.events.echoText("Aliases saved")
                return
            default:
                return
            }
        }
    }
}
