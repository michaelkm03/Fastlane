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
    func substringBeforeLocation(_ location: Int, afterCharacters characters: [Character]) -> (substring: String, preceedingCharacter: Character?, range: Range<Index>)? {
        
        guard location > 0 && self.characters.count >= location else {
            return nil
        }
        
        var matchStartIndex = characters.index(startIndex, offsetBy: location)
        let matchEndIndex = matchStartIndex
        
        var currentCharacter = Character(" ")
        var foundMatch = false
        
        while matchStartIndex != startIndex && !foundMatch {
            matchStartIndex = <#T##Collection corresponding to `matchStartIndex`##Collection#>.index(before: matchStartIndex)
            currentCharacter = self[matchStartIndex]
            foundMatch = characters.contains(currentCharacter)
        }
        
        if foundMatch {
            matchStartIndex = <#T##Collection corresponding to `matchStartIndex`##Collection#>.index(after: matchStartIndex)
        }
        let matchedCharacter: Character? = foundMatch ? currentCharacter : nil
        
        let foundRange = matchStartIndex..<matchEndIndex
        let substring = self.substring(with: foundRange)
        return (substring, matchedCharacter, foundRange)
    }
    
    /// Finds the last occurrence of the provided substring before a character from the `beforeCharacters` array and after `location`.
    ///
    /// - parameter location: The minimum start index of the returned substring
    /// - parameter beforeCharacters: Characters that, if one is encountered, mark the end of the desired substring. A character from this array will NOT be present in the returned substring.
    ///
    /// - returns: Returns nil iff the provided location is larger than the length of the string
    func substringAfterLocation(_ location: Int, beforeCharacters characters: [Character]) -> (substring: String, proceedingCharacter: Character?, range: Range<Index>)? {
        
        guard location >= 0 && self.characters.count > location else {
            return nil
        }
        
        var matchEndIndex = characters.index(startIndex, offsetBy: location)
        let matchStartIndex = matchEndIndex
        
        var currentCharacter = Character(" ")
        var foundMatch = false
        
        repeat {
            currentCharacter = self[matchEndIndex]
            foundMatch = characters.contains(currentCharacter)
            matchEndIndex = <#T##Collection corresponding to `matchEndIndex`##Collection#>.index(after: matchEndIndex)
        } while matchEndIndex != endIndex && !foundMatch
        
        if foundMatch {
            matchEndIndex = <#T##Collection corresponding to `matchEndIndex`##Collection#>.index(before: matchEndIndex)
        }
        let matchedCharacter: Character? = foundMatch ? currentCharacter : nil
        
        let foundRange = matchStartIndex..<matchEndIndex
        let substring = self.substring(with: foundRange)
        return (substring, matchedCharacter, foundRange)
    }
    
    func NSRangeFromRange(_ range : Range<String.Index>) -> NSRange {
        
        let from = String.UTF16View.Index(range.lowerBound, within: utf16)
        let to = String.UTF16View.Index(range.upperBound, within: utf16)
        return NSMakeRange(utf16.startIndex.distanceTo(from), from.distanceTo(to))
    }
}
