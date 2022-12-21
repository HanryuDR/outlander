//
//  LoadCommandHanlder.swift
//  Outlander
//
//  Created by Daniel Hillesheim on 11/30/22.
//  Copyright © 2022 Joe McBride. All rights reserved.
//
//  My second command, I want to load a profle from the command line/script

import Foundation

class LoadCommandHandler: ICommandHandler {
    private let files: FileSystem
    private let log = LogManager.getLog(String(describing: SaveCommandHandler.self))
    
    var command = "#load"

//There is a special function called init for swift classes, which is the constructor for the class.
    init(_ files: FileSystem) {
        self.files = files
    }

    func handle(_ input: String, with context: GameContext) {
//beginning _ means there is no required label for the first parameter - but there is a variable name for that parameter, input in this case.  The second parameter label is with and the variable name within the handle function is context.
        ApplicationLoader(files).load(context.applicationSettings.paths, context: context)
        ProfileLoader(files).load(context)
        context.events2.echoText("profile \(input.dropFirst(5).uppercased()) loaded")   //remove #load and echo profile in CAPS
    }
}
