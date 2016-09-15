//
//  LinkDetector.swift
//  victorious
//
//  Created by Jarod Long on 9/13/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

protocol LinkDetector {
    func detectLinks(in string: String) -> [Range<String.Index>]
    var callback: ((matchedString: String) -> Void)? { get }
}

struct SubstringLinkDetector: LinkDetector {
    var substring: String
    var callback: ((matchedString: String) -> Void)?
    
    init(substring: String, callback: ((matchedString: String) -> Void)? = nil) {
        self.substring = substring
        self.callback = callback
    }
    
    func detectLinks(in string: String) -> [Range<String.Index>] {
        var searchRange = string.startIndex ..< string.endIndex
        var ranges = [Range<String.Index>]()
        
        while let range = string.rangeOfString(substring, options: [], range: searchRange, locale: nil) {
            searchRange = range.endIndex ..< string.endIndex
            ranges.append(range)
        }
        
        return ranges
    }
}
