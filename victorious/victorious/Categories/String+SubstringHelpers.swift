//
//  String+SubstringHelpers.swift
//  victorious
//
//  Created by Sharif Ahmed on 5/17/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

extension String {
    /// Finds the first occurrence of the provided substring after a character from the `afterCharacters` array and before `location`.
    ///
    /// - parameter location: The maximum end index of the returned substring
    /// - parameter afterCharacters: Characters that, if one is encountered, mark the start of the desired substring. A character from this array will NOT be present in the returned substring.
    ///
    /// - returns: Returns nil iff the provided location is larger than the length of the string or less than 0
    func substringBeforeLocation(_ location: Int, afterCharacters characters: [Character]) -> (substring: String, preceedingCharacter: Character?, range: Range<Int>)? {
        guard location > 0 && self.characters.count >= location else {
            return nil
        }
        
        var matchStartIndex = characters.index(characters.startIndex, offsetBy: location)
        let matchEndIndex = matchStartIndex
        
        var currentCharacter = Character(" ")
        var foundMatch = false
        
        while matchStartIndex != characters.startIndex && !foundMatch {
            matchStartIndex = characters.index(before: matchStartIndex)
            currentCharacter = characters[matchStartIndex]
            foundMatch = characters.contains(currentCharacter)
        }
        
        if foundMatch {
            matchStartIndex = characters.index(after: matchStartIndex)
        }
        let matchedCharacter: Character? = foundMatch ? currentCharacter : nil
        
        let foundRange: Range<Int> = matchStartIndex ..< matchEndIndex
        
        return (String(characters[foundRange]), matchedCharacter, foundRange)
    }
    
    /// Finds the last occurrence of the provided substring before a character from the `beforeCharacters` array and after `location`.
    ///
    /// - parameter location: The minimum start index of the returned substring
    /// - parameter beforeCharacters: Characters that, if one is encountered, mark the end of the desired substring. A character from this array will NOT be present in the returned substring.
    ///
    /// - returns: Returns nil iff the provided location is larger than the length of the string
    func substringAfterLocation(_ location: Int, beforeCharacters characters: [Character]) -> (substring: String, proceedingCharacter: Character?, range: Range<Int>)? {
        guard location >= 0 && self.characters.count > location else {
            return nil
        }
        
        var matchEndIndex = characters.index(characters.startIndex, offsetBy: location)
        let matchStartIndex = matchEndIndex
        
        var currentCharacter = Character(" ")
        var foundMatch = false
        
        repeat {
            currentCharacter = characters[matchEndIndex]
            foundMatch = characters.contains(currentCharacter)
            matchEndIndex = characters.index(after: matchEndIndex)
        } while matchEndIndex != characters.endIndex && !foundMatch
        
        if foundMatch {
            matchEndIndex = characters.index(before: matchEndIndex)
        }
        let matchedCharacter: Character? = foundMatch ? currentCharacter : nil
        
        let foundRange: Range<Int> = matchStartIndex ..< matchEndIndex
        
        return (String(characters[foundRange]), matchedCharacter, foundRange)
    }
    
    func NSRangeFromRange(_ range: Range<String.Index>) -> NSRange {
        let from = String.UTF16View.Index(range.lowerBound, within: utf16)
        let to = String.UTF16View.Index(range.upperBound, within: utf16)
        return NSMakeRange(utf16.distance(from: utf16.startIndex, to: from), utf16.distance(from: from, to: to))
    }
}
