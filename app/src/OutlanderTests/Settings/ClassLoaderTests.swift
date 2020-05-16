//
//  ClassLoaderTests.swift
//  OutlanderTests
//
//  Created by Joseph McBride on 5/9/20.
//  Copyright © 2020 Joe McBride. All rights reserved.
//

import XCTest

class ClassLoaderTests: XCTestCase {

    let fileSystem = InMemoryFileSystem()
    var loader: ClassLoader?
    let context = GameContext()

    override func setUp() {
        self.loader = ClassLoader(fileSystem)
    }

    func test_load() {
        self.fileSystem.contentToLoad = "#class {app} {off}\n#class {combat} {on}"

        loader!.load(context.applicationSettings, context: context)

        XCTAssertEqual(context.classes.all().count, 2)
    }

    func test_save() {
        self.fileSystem.contentToLoad = "#class {app} {off}\n#class {combat} {on}"
        
        loader!.load(context.applicationSettings, context: context)
        loader!.save(context.applicationSettings, classes: context.classes)
        
        XCTAssertEqual(self.fileSystem.savedContent ?? "",
                       """
#class {app} {off}
#class {combat} {on}

""")
    }
}
