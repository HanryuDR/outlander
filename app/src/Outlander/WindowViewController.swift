//
//  GameWindowViewController.swift
//  Outlander
//
//  Created by Joseph McBride on 12/7/19.
//  Copyright © 2019 Joe McBride. All rights reserved.
//

import Cocoa
import Foundation

class OLScrollView : NSScrollView {
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        self.verticalScroller?.scrollerStyle = .overlay
        self.horizontalScroller?.scrollerStyle = .overlay
    }

    override open var scrollerStyle: NSScroller.Style {
        get { return .overlay }
        set
        {
            self.verticalScroller?.scrollerStyle = .overlay
            self.horizontalScroller?.scrollerStyle = .overlay
        }
    }

    override var isFlipped: Bool {
        get { return true }
    }
}

class WindowViewController : NSViewController {
    @IBOutlet var mainView: OView!
    @IBOutlet var textView: NSTextView!

    public var gameContext: GameContext?
    public var name:String = ""
    public var visible:Bool = true
    public var closedTarget:String?
    
    private var foregroundNSColor: NSColor = WindowViewController.defaultFontColor

    public var borderColor: String =  "#cccccc" {
        didSet {
            self.mainView?.borderColor = NSColor(hex: self.borderColor) ?? WindowViewController.defaultFontColor
        }
    }

    public var borderWidth: CGFloat =  1 {
        didSet {
            self.mainView?.borderWidth = self.borderWidth
        }
    }
    
    public var foregroundColor: String = "#cccccc" {
        didSet {
            self.foregroundNSColor = NSColor(hex: self.foregroundColor) ?? WindowViewController.defaultFontColor
        }
    }

    public var backgroundColor: String = "#1e1e1e" {
        didSet {
            self.textView?.backgroundColor = NSColor(hex: self.backgroundColor) ?? WindowViewController.defaultBorderColor
        }
    }

    static var defaultFontColor = NSColor(hex: "#cccccc")!
    static var defaultFont = NSFont(name: "Helvetica", size: 14)!
    static var defaultMonoFont = NSFont(name: "Menlo", size: 13)!
    static var defaultCreatureColor = NSColor(hex: "#ffff00")!
    static var defaultBorderColor = NSColor(hex: "#1e1e1e")!

    var lastTag:TextTag?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.updateTheme()

        self.textView.linkTextAttributes = [
            NSAttributedString.Key.foregroundColor: WindowViewController.defaultFontColor,
            NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue,
            NSAttributedString.Key.cursor: NSCursor.pointingHand
        ]
    }
    
    func updateTheme() {
        self.mainView?.backgroundColor = NSColor(hex: self.borderColor) ?? WindowViewController.defaultFontColor
        self.textView?.backgroundColor = NSColor(hex: self.backgroundColor) ?? WindowViewController.defaultBorderColor
    }

    func clear() {
        DispatchQueue.main.async {
            self.textView.string = ""
        }
    }

    func clearAndAppend(_ tags: [TextTag]) {
        let target = NSMutableAttributedString()

        for tag in tags {
            if let str = stringFromTag(tag) {
                target.append(str)
            }
        }
        
        set(target)
    }
    
    func stringFromTag(_ tag: TextTag) -> NSAttributedString? {
        
        guard let context = self.gameContext else {
            return nil
        }
        
        var foregroundColorToUse = self.foregroundNSColor
        
        if tag.bold {
            if let value = context.presetFor("creatures") {
                foregroundColorToUse = NSColor(hex: value.color) ?? WindowViewController.defaultCreatureColor
            }
        }

        if let preset = tag.preset {
            if let value = context.presetFor(preset) {
                foregroundColorToUse = NSColor(hex: value.color) ?? self.foregroundNSColor
            }
        }

        var font = WindowViewController.defaultFont
        if tag.mono {
            font = WindowViewController.defaultMonoFont
        }

        var attributes:[NSAttributedString.Key:Any] = [
            NSAttributedString.Key.foregroundColor: foregroundColorToUse,
            NSAttributedString.Key.font: font
        ]
        
        if let bgColor = tag.backgroundColor {
            attributes[NSAttributedString.Key.backgroundColor] = NSColor(hex: bgColor) ?? nil
        }

        if let href = tag.href {
            attributes[NSAttributedString.Key.link] = href
        }

        if let command = tag.command {
            attributes[NSAttributedString.Key.link] = "command:\(command)"
        }

        return NSAttributedString(string: tag.text, attributes: attributes)
    }

    func append(_ tag: TextTag) {

        if self.lastTag?.isPrompt == true && !tag.playerCommand {
            // skip multiple prompts of the same type
            if tag.isPrompt && self.lastTag?.text == tag.text {
                return
            }
            
            // TODO: ignore highlights, etc.
            append(NSAttributedString(string: "\n"))
        }

        guard let str = stringFromTag(tag) else { return }

        append(str)

        self.lastTag = tag
    }

    func append(_ text: NSAttributedString) {
        DispatchQueue.main.async {
            let smartScroll = self.textView.visibleRect.maxY == self.textView.bounds.maxY
            
            self.textView.textStorage?.append(text)
            
            if smartScroll {
                self.textView.scrollToEndOfDocument(self)
            }
        }
    }

    func set(_ text: NSAttributedString) {
        DispatchQueue.main.async {
            let smartScroll = self.textView.visibleRect.maxY == self.textView.bounds.maxY

            self.textView.textStorage?.setAttributedString(text)
            
            if smartScroll {
                self.textView.scrollToEndOfDocument(self)
            }
        }
    }
}
