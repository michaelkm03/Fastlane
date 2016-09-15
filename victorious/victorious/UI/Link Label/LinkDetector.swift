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

struct SubstringLinkDetector: LinkDetector {
    var substring: String
    var callback: ((matchedString: String) -> Void)?
    
    init(substring: String, callback: ((matchedString: String) -> Void)? = nil) {
        self.substring = substring
        self.callback = callback
    }
    
    func detectLinks(string string: String) -> [Range<String.Index>] {
        if let range = string.rangeOfString(substring) {
            return [range]
        }
        
        return []
    }
}
