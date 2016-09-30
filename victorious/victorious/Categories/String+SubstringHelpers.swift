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
    func substringBeforeLocation(location: Int, afterCharacters characters: [Character]) -> (substring: String, preceedingCharacter: Character?, range: Range<String.Index>)? {
        
        guard location > 0 && self.characters.count >= location else {
            return nil
        }
        
        var matchStartIndex = index(startIndex, offsetBy: location)
        let matchEndIndex = matchStartIndex
        
        var currentCharacter = Character(" ")
        var foundMatch = false
        
        while matchStartIndex != startIndex && !foundMatch {
            matchStartIndex = index(before: matchStartIndex)
            currentCharacter = self[matchStartIndex]
            foundMatch = characters.contains(currentCharacter)
        }
        
        if foundMatch {
            matchStartIndex = index(after: matchStartIndex)
        }
        let matchedCharacter: Character? = foundMatch ? currentCharacter : nil
        
        let foundRange = matchStartIndex..<matchEndIndex
        let sub = substring(with: foundRange)
        return (sub, matchedCharacter, foundRange)
    }
    
    /// Finds the last occurrence of the provided substring before a character from the `beforeCharacters` array and after `location`.
    ///
    /// - parameter location: The minimum start index of the returned substring
    /// - parameter beforeCharacters: Characters that, if one is encountered, mark the end of the desired substring. A character from this array will NOT be present in the returned substring.
    ///
    /// - returns: Returns nil iff the provided location is larger than the length of the string
    func substringAfterLocation(location: Int, beforeCharacters characters: [Character]) -> (substring: String, proceedingCharacter: Character?, range: Range<Index>)? {
        
        guard location >= 0 && self.characters.count > location else {
            return nil
        }
        
        var matchEndIndex = index(startIndex, offsetBy: location)
        let matchStartIndex = matchEndIndex
        
        var currentCharacter = Character(" ")
        var foundMatch = false
        
        repeat {
            currentCharacter = self[matchEndIndex]
            foundMatch = characters.contains(currentCharacter)
            matchEndIndex = index(after: matchEndIndex)
        } while matchEndIndex != endIndex && !foundMatch
        
        if foundMatch {
            matchEndIndex = index(before: matchEndIndex)
        }
        let matchedCharacter: Character? = foundMatch ? currentCharacter : nil
        
        let foundRange = matchStartIndex..<matchEndIndex
        let sub = substring(with: foundRange)
        return (sub, matchedCharacter, foundRange)
    }
    
    func NSRangeFromRange(range : Range<String.Index>) -> NSRange {
        
        let from = String.UTF16View.Index(range.lowerBound, within: utf16)
        let to = String.UTF16View.Index(range.upperBound, within: utf16)
        
        let location = utf16.distance(from: utf16.startIndex, to: from)
        let length = utf16.distance(from: from, to: to)
        
        return NSMakeRange(location, length)
    }
}
