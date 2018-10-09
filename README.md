# RegexTester
A simple Mac app for making Swift regex patterns.

![Screenshot of app showing a matched Git log](regextester.gif)

Regex is displayed in a "normal" text field, above, so that you can edit it easily, and below it is an "escaped" text field. These fields mirror each other as you go.

The `opts` button allows you to toggle all the options in the `NSRegularExpression.Options` option set, and `copy` produces:

```swift
let regexStr = "commit ([0-9a-f]{40}).*?(Merge: [0-9a-f ]{15}\\n)?\\nAuthor: (.*?)\\nDate:   (.*?)\\n(.*?\\n\\n)"
let regex = try? NSRegularExpression(pattern: regexStr, options: [.dotMatchesLineSeparators])
```

which you can paste into your code and mod at will.*

### Attribution

Written by Steve Sparks ([@barbecuesteve](http://www.barbecuesteve.com/)), 
engineer at [Big Nerd Ranch](https://www.bignerdranch.com/). Screenshot shows a portion of the git log of BNR's [Deferred](https://github.com/bignerdranch/Deferred) library.

### Known Issues

Some expressions can cause the beachball of death due to 
[catastrophic backtracking](https://www.regular-expressions.info/catastrophic.html). 
No attempt is taken to limit the greediness of your expression. 
You've been warned. Kill it and restart it. 

### Contributing

Please do! Open a pull request.

--

*Personally I do it this way. It is more maintainable.

```swift
extension NSRegularExpression {

    enum Regex: String {
        case gitLogEntry = "commit ([0-9a-f]{40}).*?(Merge: [0-9a-f ]{15}\n)?\nAuthor: (.*?)\nDate: (.*?)\n\n(.*?)\n\n"
    }

    convenience init(regex: Regex, options: NSRegularExpression.Options) throws {
        try self.init(pattern: regex.rawValue, options: options)
    }
}

let myRegex = try NSRegularExpression(regex: .gitLogEntry, options: [.dotMatchesLineSeparators])
```
