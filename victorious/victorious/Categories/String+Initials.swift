//
//  String+Initials.swift
//  victorious
//
//  Created by Jarod Long on 7/6/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

extension String {
    /// Returns the initials of `self`, a concatenation of the uppercase first characters of each word (determined by
    /// splitting on whitespace) in the string.
    func initials(maxCount maxCount: Int = 2) -> String {
        let words = componentsSeparatedByCharactersInSet(.whitespaceAndNewlineCharacterSet())
        let initialCount = min(words.count, maxCount)
        let lastIndex = initialCount - 1
        
        let initials: [String] = (0 ..< initialCount).map { index in
            switch index {
                case 0:         return words[0].uppercaseFirstCharacter
                case lastIndex: return words.last?.uppercaseFirstCharacter ?? ""
                default:        return words[index].uppercaseFirstCharacter
            }
        }
        
        return initials.joinWithSeparator("")
    }
    
    private var uppercaseFirstCharacter: String {
        guard let character = characters.first else {
            return ""
        }
        
        return String(character).uppercaseString
    }
}
