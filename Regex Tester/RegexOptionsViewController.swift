//
//  RegexOptionsViewController.swift
//  Regex Tester
//
//  Created by Steve Sparks on 10/7/18.
//  Copyright © 2018 SOG. All rights reserved.
//

import Cocoa

class RegexOptionsViewController: NSViewController {
    @IBOutlet var caseInsensitiveButton: NSButton!
    @IBOutlet var allowsCommentsButton: NSButton!
    @IBOutlet var ignoreMetacharactersButton: NSButton!
    @IBOutlet var dotMatchesLineSeparatorsButton: NSButton!
    @IBOutlet var anchorsMatchLinesButton: NSButton!
    @IBOutlet var useUnixLineSeparatorsButton: NSButton!
    @IBOutlet var useUnicodeWordBoundariesButton: NSButton!
    @IBOutlet var highlightSubgroupsButton: NSButton!

    var options = NSRegularExpression.Options()
    var highlightSubgroups = true

    func updateOptionsFromButtons() {
        var opts = NSRegularExpression.Options()

        if caseInsensitiveButton.state == .on { opts = [opts, .caseInsensitive] }
        if allowsCommentsButton.state == .on { opts = [opts, .allowCommentsAndWhitespace] }
        if ignoreMetacharactersButton.state == .on { opts = [opts, .ignoreMetacharacters] }
        if dotMatchesLineSeparatorsButton.state == .on { opts = [opts, .dotMatchesLineSeparators] }
        if anchorsMatchLinesButton.state == .on { opts = [opts, .anchorsMatchLines] }
        if useUnixLineSeparatorsButton.state == .on { opts = [opts, .useUnixLineSeparators] }
        if useUnicodeWordBoundariesButton.state == .on { opts = [opts, .useUnicodeWordBoundaries] }

        highlightSubgroups = (highlightSubgroupsButton.state == .on)
        options = opts
    }

    func setButtonsFromOptions() {
        let options = self.options
        caseInsensitiveButton.state = options.contains(.caseInsensitive) ? .on : .off
        allowsCommentsButton.state = options.contains(.allowCommentsAndWhitespace) ? .on : .off
        ignoreMetacharactersButton.state = options.contains(.ignoreMetacharacters) ? .on : .off
        dotMatchesLineSeparatorsButton.state = options.contains(.dotMatchesLineSeparators) ? .on : .off
        anchorsMatchLinesButton.state = options.contains(.anchorsMatchLines) ? .on : .off
        useUnixLineSeparatorsButton.state = options.contains(.useUnixLineSeparators) ? .on : .off
        useUnicodeWordBoundariesButton.state = options.contains(.useUnicodeWordBoundaries) ? .on : .off
        highlightSubgroupsButton.state = highlightSubgroups ? .on : .off
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }

    override func viewWillAppear() {
        super.viewWillAppear()
        setButtonsFromOptions()
    }

    @IBAction func didChangeButton(_ sender: Any?) {
        updateOptionsFromButtons()
    }

    @IBAction func didTapDone(_ sender: Any?) {
        let application = NSApplication.shared
        application.stopModal()
    }
    
}
