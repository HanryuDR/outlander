//
//  WindowCommandHandler.swift
//  Outlander
//
//  Created by Joseph McBride on 5/1/20.
//  Copyright © 2020 Joe McBride. All rights reserved.
//

import Foundation

class WindowCommandHandler : ICommandHandler {

    let command = "#window"

    let validCommands = ["add", "clear", "hide", "list", "reload", "load", "show"]

    let regex = try? Regex("^(\\w+)(\\s(\\w+))?$")

    func handle(command: String, withContext: GameContext) {
        var commands = command[7...].trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)

        if commands.hasPrefix("reload") || commands.hasPrefix("load") {
            let loader = WindowLayoutLoader(LocalFileSystem(withContext.applicationSettings))
            if let layout = loader.load(withContext.applicationSettings, file: "default.cfg") {
                withContext.layout = layout
                withContext.events.post("ol:window", data: ["action":"reload", "window":""])
            }
            return
        }

        guard let matches = self.regex?.firstMatch(&commands) else {
            return
        }

        let action = matches.valueAt(index: 1) ?? ""
        let window = matches.valueAt(index: 3) ?? ""
        
        if validCommands.contains(action) {
            withContext.events.post("ol:window", data: ["action":action, "window":window])
        }
    }
}
