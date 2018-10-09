//
//  NSRegularExpression+Extensions.swift
//  Regex Tester
//
//  Created by Steve Sparks on 10/9/18.
//  Copyright © 2018 SOG. All rights reserved.
//

import AppKit

extension NSRegularExpression.Options {

    var stringValue: String {
        var optionStrings = [String]()
        if contains(.allowCommentsAndWhitespace) {
            optionStrings.append(".allowCommentsAndWhitespace")
        }
        if contains(.anchorsMatchLines) {
            optionStrings.append(".anchorsMatchLines")
        }
        if contains(.caseInsensitive) {
            optionStrings.append(".caseInsensitive")
        }
        if contains(.dotMatchesLineSeparators) {
            optionStrings.append(".dotMatchesLineSeparators")
        }
        if contains(.ignoreMetacharacters) {
            optionStrings.append(".ignoreMetacharacters")
        }
        if contains(.useUnixLineSeparators) {
            optionStrings.append(".useUnixLineSeparators")
        }
        if contains(.useUnicodeWordBoundaries) {
            optionStrings.append(".useUnicodeWordBoundaries")
        }

        return "[\(optionStrings.joined(separator: ", "))]"
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
            highlightHue = fmod(highlightHue + 0.131, 1.0)

            let rangeCount = highlightSubgroups ? result.numberOfRanges : 1
            while rangeCtr < rangeCount {
                let range = result.range(at: rangeCtr)
                let mod = (CGFloat(rangeCtr) * 0.05)
                let color = NSColor(hue: highlightHue, saturation: 0.15 + mod, brightness: (1.0 - mod), alpha: 1.0)
                retval.setAttributes([.backgroundColor: color], range: range)
                rangeCtr += 1
            }
        }
        return (retval, matches.count)
    }
}
