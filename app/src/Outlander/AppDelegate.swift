//
//  AppDelegate.swift
//  Outlander
//
//  Created by Joseph McBride on 7/18/19.
//  Copyright © 2019 Joe McBride. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    var windows: [NSWindow] = []
    var rootUrl: URL?

    var activeWindow: NSWindow? {
        var win = NSApplication.shared.keyWindow

        if win == nil, windows.count > 0 {
            win = windows[0]
        }

        return win
    }

    var activeController: GameViewController? {
        activeWindow?.contentViewController as? GameViewController
    }

    func applicationDidFinishLaunching(_: Notification) {
        LogManager.getLog = { name in
            PrintLogger(name)
        }

        AppDelegate.mainMenu.instantiate(withOwner: NSApplication.shared, topLevelObjects: nil)

        Preferences.workingDirectoryBookmark = nil

        if let rootUrl = BookmarkHelper().promptOrRestore() {
            self.rootUrl = rootUrl
        }

        makeWindow(rootUrl)
    }

    func makeWindow(_ rootUrl: URL?) {
        let bundle = Bundle(for: GameViewController.self)
        let storyboard = NSStoryboard(name: "Game", bundle: bundle)

        let window = OWindow(
            contentRect: NSMakeRect(0, 0, NSScreen.main!.frame.midX, NSScreen.main!.frame.midY),
            styleMask: [.titled, .resizable, .closable, .miniaturizable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        window.setFrameAutosaveName("")

        window.title = "Outlander 2"
        window.center()
        window.isMovableByWindowBackground = true
        window.titlebarAppearsTransparent = true

        let controller = storyboard.instantiateInitialController() as! GameViewController
        window.registerKeyHandlers(controller.gameContext)

        let settings = ApplicationSettings()
        if let root = rootUrl {
            settings.paths.rootUrl = root
        }
        controller.applicationSettings = settings

        ApplicationLoader(LocalFileSystem(settings)).load(settings.paths, context: controller.gameContext)

        window.contentViewController = controller
        window.delegate = controller

        window.makeKeyAndOrderFront(nil)

        windows.append(window)
    }

    func applicationWillTerminate(_: Notification) {
        windows.removeAll()
    }

    @IBAction func preferences(_: Any) {
        print("Preferences")
    }

    @IBAction func connect(_: Any) {
        activeController?.showLogin()
    }

    @IBAction func connectProfile(_: Any) {
        activeController?.showProfileSelection()
    }

    @IBAction func saveProfile(_: Any) {
        sendCommand("profile:save")
    }

    @IBAction func newGame(_: Any) {
        makeWindow(rootUrl)
    }

    @IBAction func showMapWindow(_: Any) {
        sendCommand("show:mapwindow")
    }

    @IBAction func loadDefaultLayoutAction(_: Any) {
        sendCommand("layout:LoadDefault")
    }

    @IBAction func saveDefaultLayoutAction(_: Any) {
        sendCommand("layout:SaveDefault")
    }

    @IBAction func loadLayoutAction(_: Any) {
        sendCommand("layout:Load")
    }

    @IBAction func saveLayoutAsAction(_: Any) {
        sendCommand("layout:SaveAs")
    }

    func sendCommand(_ command: String) {
        activeController?.command(command)
    }

    static var mainMenu: NSNib {
        guard let nib = NSNib(nibNamed: NSNib.Name("MainMenu"), bundle: Bundle.main) else {
            fatalError("Resource `MainMenu.xib` is not found in the bundle `\(Bundle.main.bundlePath)`")
        }
        return nib
    }
}
