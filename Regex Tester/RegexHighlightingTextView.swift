//
//  RegexHighlightingTextView.swift
//  Regex Tester
//
//  Created by Steve Sparks on 10/9/18.
//  Copyright © 2018 SOG. All rights reserved.
//

import AppKit

class RegexHighlightingTextView: NSTextView {
    var regex: NSRegularExpression? {
        didSet {
            resetTextForRegex()
        }
    }
    var options = NSRegularExpression.Options() {
        didSet {
            resetTextForRegex()
        }
    }
    var highlightSubgroups = true {
        didSet {
            resetTextForRegex()
        }
    }

    var numberOfMatches = 0

    @discardableResult
    func resetTextForRegex() -> (Int) {
        guard let insertionPoint = selectedRanges.first as? NSRange else {
            preconditionFailure("No selection point")
        }

        let (attr, count) = string.attributedString(highlightedWithRegex: self.regex, highlightSubgroups: highlightSubgroups)
        textStorage?.setAttributedString(attr)

        backgroundColor = .white
        textColor = .black
        setSelectedRange(insertionPoint)
        if let font = NSFont(name: "Anonymous", size: 12) {
            self.font = font
        }

        numberOfMatches = count
        return count
    }
}
