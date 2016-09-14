//
//  LinkDetector.swift
//  victorious
//
//  Created by Jarod Long on 9/13/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

protocol LinkDetector {
    func detectLinks(string string: String) -> [Range<String.Index>]
    var callback: ((matchedString: String) -> Void)? { get }
}

struct RangeLinkDetector: LinkDetector {
    var ranges: [Range<String.Index>] = []
    var callback: ((matchedString: String) -> Void)?
    
    init(ranges: [Range<String.Index>], callback: ((matchedString: String) -> Void)? = nil) {
        self.ranges = ranges
        self.callback = callback
    }
    
    func detectLinks(string string: String) -> [Range<String.Index>] {
        return ranges
    }
}

struct SubstringLinkDetector: LinkDetector {
    var substring: String
    var callback: ((matchedString: String) -> Void)?
    
    init(substring: String, callback: ((matchedString: String) -> Void)? = nil) {
        self.substring = substring
        self.callback  = callback
    }
    
    func detectLinks(string string: String) -> [Range<String.Index>] {
        print("detecting links for '\(substring)' in:", string)
        
        if let range = string.rangeOfString(substring) {
            print("  found it", range)
            return [range]
        }
        
        return []
    }
}

struct RegexLinkDetector: LinkDetector {
    static func usernameLinkDetector(callback callback: ((matchedString: String) -> Void)? = nil) -> RegexLinkDetector {
        return RegexLinkDetector(pattern: "(?<!\\w)@([\\w\\_]+)?", options: .CaseInsensitive, callback: callback)
    }
    
    static func hashtagLinkDetector(callback callback: ((matchedString: String) -> Void)? = nil) -> RegexLinkDetector {
        return RegexLinkDetector(pattern: "(?<!\\w)#([\\w\\_]+)?", options: .CaseInsensitive, callback: callback)
    }
    
    static func urlLinkDetector(callback callback: ((matchedString: String) -> Void)? = nil) -> RegexLinkDetector {
        return RegexLinkDetector(regex: try! NSDataDetector(types: NSTextCheckingType.Link.rawValue), callback: callback)
    }
    
    init(pattern: String, options: NSRegularExpressionOptions, callback: ((matchedString: String) -> Void)? = nil) {
        self.init(regex: try! NSRegularExpression(pattern: pattern, options: options), callback: callback)
    }
    
    init(regex: NSRegularExpression, callback: ((matchedString: String) -> Void)? = nil) {
        self.regex = regex
        self.callback = callback
    }
    
    var regex: NSRegularExpression
    var callback: ((matchedString: String) -> Void)?
    
    func detectLinks(string string: String) -> [Range<String.Index>] {
        let length = string.characters.count
        
        return regex.matchesInString(string, options: .ReportCompletion, range: NSRange(location: 0, length: length)).map { match in
            let range = match.range
            return string.startIndex.advancedBy(range.location) ..< string.startIndex.advancedBy(range.location + range.length)
        }
    }
}
