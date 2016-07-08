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
    func substringBeforeLocation(location: Int, afterCharacters characters: [Character]) -> (substring: String, preceedingCharacter: Character?, range: Range<Index>)? {
        
        guard location > 0 && self.characters.count >= location else {
            return nil
        }
        
        var matchStartIndex = startIndex.advancedBy(location)
        let matchEndIndex = matchStartIndex
        
        var currentCharacter = Character(" ")
        var foundMatch = false
        
        while matchStartIndex != startIndex && !foundMatch {
            matchStartIndex = matchStartIndex.predecessor()
            currentCharacter = self[matchStartIndex]
            foundMatch = characters.contains(currentCharacter)
        }
        
        if foundMatch {
            matchStartIndex = matchStartIndex.successor()
        }
        let matchedCharacter: Character? = foundMatch ? currentCharacter : nil
        
        let foundRange = matchStartIndex..<matchEndIndex
        let substring = substringWithRange(foundRange)
        return (substring, matchedCharacter, foundRange)
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
        
        var matchEndIndex = startIndex.advancedBy(location)
        let matchStartIndex = matchEndIndex
        
        var currentCharacter = Character(" ")
        var foundMatch = false
        
        repeat {
            currentCharacter = self[matchEndIndex]
            foundMatch = characters.contains(currentCharacter)
            matchEndIndex = matchEndIndex.successor()
        } while matchEndIndex != endIndex && !foundMatch
        
        if foundMatch {
            matchEndIndex = matchEndIndex.predecessor()
        }
        let matchedCharacter: Character? = foundMatch ? currentCharacter : nil
        
        let foundRange = matchStartIndex..<matchEndIndex
        let substring = substringWithRange(foundRange)
        return (substring, matchedCharacter, foundRange)
    }
    
    func NSRangeFromRange(range : Range<String.Index>) -> NSRange {
        
        let from = String.UTF16View.Index(range.startIndex, within: utf16)
        let to = String.UTF16View.Index(range.endIndex, within: utf16)
        return NSMakeRange(utf16.startIndex.distanceTo(from), from.distanceTo(to))
    }
}
