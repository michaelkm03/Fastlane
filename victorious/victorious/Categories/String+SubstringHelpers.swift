//
//  String+SubstringHelpers.swift
//  victorious
//
//  Created by Sharif Ahmed on 5/17/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

extension String {
    
    func substringBeforeLocation(location: Int, afterCharacters characters: [Character]) -> (substring: String?, preceedingCharacter: Character?) {
        
        guard self.characters.count > location else {
            return (nil, nil)
        }
        
        let substring: NSString = (self as NSString).substringToIndex(location)
        
        var currentLocation = location
        var currentCharacter = Character("")
        var foundMatch = false
        
        repeat {
            currentLocation -= 1
            currentCharacter = Character(UnicodeScalar(substring.characterAtIndex(currentLocation)))
            foundMatch = characters.contains(currentCharacter)
        } while currentLocation > 0 && !foundMatch
        
        if foundMatch {
            let matchStartLocation = currentLocation + 1
            let matchedSubstring = substring.substringWithRange(NSMakeRange(matchStartLocation, location - matchStartLocation))
            return (matchedSubstring, currentCharacter)
        }
        return (nil, nil)
    }
}
