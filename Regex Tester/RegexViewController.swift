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

    @IBOutlet var textView: NSTextView!
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
        guard let insertionPoint = self.textView.selectedRanges.first as? NSRange else {
            preconditionFailure("GERP")
        }
        do {
            self.regex = try NSRegularExpression(pattern: normRegexField.stringValue, options: self.options)
            normLabel.textColor = .black
            let (attr, count) = self.textView.string.attributedString(highlightedWithRegex: self.regex, highlightSubgroups: highlightSubgroups)
            self.textView.textStorage?.setAttributedString(attr)
            self.statusLabel.stringValue = "Found \(count) instances."
        } catch {
            normLabel.textColor = .red
            statusLabel.stringValue = "Malformed regex."
        }

        self.textView.backgroundColor = .white
        self.textView.textColor = .black
        self.textView.setSelectedRange(insertionPoint)
        if let font = NSFont(name: "Anonymous", size: 12) {
            textView.font = font
        }
    }

    @IBAction func didTapCopy(_ sender: Any?) {
        let output = "let regex = try? NSRegularExpression(pattern: \"\(escapedRegexField.stringValue)\", options: [.dotMatchesLineSeparators])"
        NSPasteboard.general.clearContents()
        print(" \(NSPasteboard.general.setString(output, forType: .string))")
    }

    @IBAction func didTapOptions(_ sender: Any?) {
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        let optionsWindowController = storyboard.instantiateController(withIdentifier: "options") as! NSWindowController
        if let window = optionsWindowController.window,
            let vc = optionsWindowController.contentViewController as? RegexOptionsViewController {
            vc.options = self.options
            vc.highlightSubgroups = self.highlightSubgroups
            let application = NSApplication.shared
            application.runModal(for: window)
            self.options = vc.options
            self.highlightSubgroups = vc.highlightSubgroups
            window.close()
            resetViews()
        } else {
            print("FML")
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


extension String {
    func attributedString(highlightedWithRegex regex: NSRegularExpression? = nil, highlightSubgroups: Bool = true) -> (NSAttributedString, Int) {
        let retval = NSMutableAttributedString(string: self)
        guard let regex = regex else {
            return (retval, 0)
        }

        var highlightHue: CGFloat = 0.0
        let matches = regex.matches(in: self, range: NSMakeRange(0, utf16.count))

        for result in matches {
            var rangeCtr = 0
            highlightHue = fmod(highlightHue + 0.11, 1.0)

            let rangeCount = highlightSubgroups ? result.numberOfRanges : 1
            while rangeCtr < rangeCount {
                let range = result.range(at: rangeCtr)
                let mod = (CGFloat(rangeCtr) * 0.05)
                let color = NSColor(hue: highlightHue, saturation: 0.1 + mod, brightness: (1.0 - mod), alpha: 1.0)
                retval.setAttributes([.backgroundColor: color], range: range)
                rangeCtr += 1
            }
            print("dd > \(result.numberOfRanges)")
        }
        return (retval, matches.count)
    }
}

extension RegexViewController {

    enum RestorationKeys: String {
        case escapedRegex
        case normalRegex
        case textViewString
    }

    override func encodeRestorableState(with coder: NSCoder) {
        coder.encode(escapedRegexField.stringValue, forKey: RestorationKeys.escapedRegex.rawValue)
        coder.encode(normRegexField.stringValue, forKey: RestorationKeys.normalRegex.rawValue)
        coder.encode(textView.string, forKey: RestorationKeys.textViewString.rawValue)
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
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            self.resetViews()
        }
    }
}
