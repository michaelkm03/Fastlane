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
    /// - parameter afterCharacters: An array of characters
    ///
    /// - returns: Returns nil iff the provided location is larger than the length of the string or less than 0
    func substringBeforeLocation(location: Int, afterCharacters characters: [Character]) -> (substring: String, preceedingCharacter: Character?, range: NSRange)? {
        
        guard self.characters.count >= location &&
            location > 0 else {
            return nil
        }
        
        let substring: NSString = (self as NSString).substringToIndex(location)
        
        var currentLocation = location
        var currentCharacter = Character(" ")
        var foundMatch = false
        
        repeat {
            currentLocation -= 1
            currentCharacter = Character(UnicodeScalar(substring.characterAtIndex(currentLocation)))
            foundMatch = characters.contains(currentCharacter)
        } while currentLocation > 0 && !foundMatch
        
        if foundMatch {
            let matchStartLocation = currentLocation + 1
            let foundRange = NSMakeRange(matchStartLocation, location - matchStartLocation)
            let matchedSubstring = substring.substringWithRange(foundRange)
            return (matchedSubstring, currentCharacter, foundRange)
        }
        return (substring as String, nil, NSMakeRange(0, substring.length))
    }
    
    /// Finds the last occurrence of the provided substring before a character from the `beforeCharacters` array and after `location`.
    ///
    /// - parameter location: The minimum start index of the returned substring
    /// - parameter beforeCharacters: An array of characters
    ///
    /// - returns: Returns nil iff the provided location is larger than the length of the string
    func substringAfterLocation(location: Int, beforeCharacters characters: [Character]) -> (substring: String, proceedingCharacter: Character?, range: NSRange)? {
        
        let startLocation = location + 1
        guard self.characters.count > startLocation &&
            startLocation >= 0 else {
                return nil
        }
        
        let substring: NSString =
            (self as NSString).substringFromIndex(startLocation)
        
        var currentLocation = -1
        var currentCharacter = Character(" ")
        var foundMatch = false
        
        repeat {
            currentLocation += 1
            currentCharacter = Character(UnicodeScalar(substring.characterAtIndex(currentLocation)))
            foundMatch = characters.contains(currentCharacter)
        } while currentLocation < substring.length - 1 && !foundMatch
        
        if foundMatch {
            let matchFinishLocation = currentLocation
            let foundRange = NSMakeRange(0, matchFinishLocation)
            let matchedSubstring = substring.substringWithRange(foundRange)
            let range = NSMakeRange(startLocation + foundRange.location, foundRange.length)
            return (matchedSubstring, currentCharacter, range)
        }
        return (substring as String, nil, NSMakeRange(self.characters.count - substring.length, substring.length))
    }
}
