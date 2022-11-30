//
//  SaveCommandHandler.swift
//  Outlander
//
//  Created by Daniel Hillesheim on 11/29/22.
//  Copyright © 2022 Joe McBride. All rights reserved.
//
//  My first command, I'm trying to have this just save everything
//  Often I'll get crashes and I wish that the varialbes file had been saved
//  The idea is I'll sprinkle this into my scripts
//  This is basically an alias for #var save, but for everythign and it was an easy first project

import Foundation

class SaveCommandHandler: ICommandHandler {
    private let files: FileSystem
    private let log = LogManager.getLog(String(describing: SaveCommandHandler.self))
    
    var command = "#save"

    init(_ files: FileSystem) {
        self.files = files
    }

    func handle(_ input: String, with context: GameContext) {
        ApplicationLoader(files).save(context.applicationSettings.paths, context: context)
        ProfileLoader(files).save(context)
        context.events2.echoText("settings saved")
    }
}
