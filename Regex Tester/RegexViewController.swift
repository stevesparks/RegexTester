//
//  RegexViewController.swift
//  GANK
//
//  Created by Steve Sparks on 10/5/18.
//  Copyright © 2018 SOG. All rights reserved.
//

import Cocoa

class RegexViewController: NSViewController {
    @IBOutlet var normRegexField: NSTextField!

    @IBOutlet var normLabel: NSTextFieldCell!
    @IBOutlet var escapedRegexField: NSTextField!
    @IBOutlet var statusLabel: NSTextField!

    @IBOutlet var textView: RegexHighlightingTextView!
    var highlightSubgroups = true

    var options: NSRegularExpression.Options = [.dotMatchesLineSeparators]

    override func viewDidLoad() {
        super.viewDidLoad()
        textView.delegate = self
        normRegexField.delegate = self
        escapedRegexField.delegate = self
        // Do any additional setup after loading the view.
    }

    var regex: NSRegularExpression?

    func resetViews() {
        do {
            self.regex = nil
            self.regex = try NSRegularExpression(pattern: normRegexField.stringValue, options: self.options)
            normLabel.textColor = .black
            textView.regex = self.regex
            let count = textView.numberOfMatches
            self.statusLabel.stringValue = "Found \(count) instances. Options = \(options.stringValue)"
        } catch {
            normLabel.textColor = .red
            statusLabel.stringValue = "Malformed regex."
        }
    }

    @IBAction func didTapCopy(_ sender: Any?) {
        // Don't copy bad regex
        guard regex != nil else { return }

        let output = ["let regexStr = \"\(escapedRegexField.stringValue)\"",
            "let regex = try? NSRegularExpression(pattern: regexStr, options: [\(options.stringValue)])"].joined(separator: "\n")
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(output, forType: .string)
    }

    @IBAction func didTapOptions(_ sender: Any?) {
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        let optionsWindowController = storyboard.instantiateController(withIdentifier: "options") as! NSWindowController
        if let window = optionsWindowController.window,
            let vc = optionsWindowController.contentViewController as? RegexOptionsViewController {
            vc.options = self.options
            vc.highlightSubgroups = self.highlightSubgroups

            window.center()
            let application = NSApplication.shared
            application.runModal(for: window)

            self.options = vc.options
            self.highlightSubgroups = vc.highlightSubgroups
            textView.options = vc.options
            textView.highlightSubgroups = vc.highlightSubgroups
            window.close()
            resetViews()
        } else {
            print("No storyboard found")
        }
    }
}

extension RegexViewController: NSTextFieldDelegate {
    func controlTextDidChange(_ obj: Notification) {
        if let object = obj.object as? NSTextField, let norm = normRegexField, object == norm {
            normalToEscaped()
        } else if let object = obj.object as? NSTextField, let norm = escapedRegexField, object == norm {
            escapedToNormal()
        } else {

        }
        resetViews()
        invalidateRestorableState()
    }

    @IBAction func escapedTextDidChange(_ sender: Any) {
        escapedToNormal()
        resetViews()
        invalidateRestorableState()
    }

    @IBAction func normalTextDidChange(_ sender: Any) {
        normalToEscaped()
        resetViews()
        invalidateRestorableState()
    }

    func escapedToNormal() {
        var str = escapedRegexField.stringValue
        str = str.replacingOccurrences(of: "\\\\", with: "{:o:}")
        str = str.replacingOccurrences(of: "{:o:}", with: "\\")
        str = str.replacingOccurrences(of: "\\\"", with: "\"")
        normRegexField.stringValue = str
        invalidateRestorableState()
    }

    func normalToEscaped() {
        var str = normRegexField.stringValue
        str = str.replacingOccurrences(of: "\\", with: "\\\\")
        str = str.replacingOccurrences(of: "\"", with: "\\\"")
        escapedRegexField.stringValue = str
        invalidateRestorableState()
    }
}

extension RegexViewController: NSTextViewDelegate {
    func textDidChange(_ notification: Notification) {
        resetViews()
        invalidateRestorableState()
    }
}

extension RegexViewController {

    enum RestorationKeys: String {
        case escapedRegex
        case normalRegex
        case textViewString
        case options
    }

    override func encodeRestorableState(with coder: NSCoder) {
        coder.encode(escapedRegexField.stringValue, forKey: RestorationKeys.escapedRegex.rawValue)
        coder.encode(normRegexField.stringValue, forKey: RestorationKeys.normalRegex.rawValue)
        coder.encode(textView.string, forKey: RestorationKeys.textViewString.rawValue)
        coder.encode(options, forKey: RestorationKeys.options.rawValue)
    }

    override func restoreState(with coder: NSCoder) {
        if let str = coder.decodeObject(forKey: RestorationKeys.escapedRegex.rawValue) as? String {
            escapedRegexField.stringValue = str
        }
        if let str = coder.decodeObject(forKey: RestorationKeys.normalRegex.rawValue) as? String {
            normRegexField.stringValue = str
        }
        if let str = coder.decodeObject(forKey: RestorationKeys.textViewString.rawValue) as? String {
            textView.string = str
        }
        if let opts = coder.decodeObject(forKey: RestorationKeys.options.rawValue) as? NSRegularExpression.Options {
            options = opts
        }
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            self.resetViews()
        }
    }
}
