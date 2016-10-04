//
//  String+SubstringHelpersTests.swift
//  victorious
//
//  Created by Sharif Ahmed on 5/20/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

@testable import victorious
import XCTest

class String_SubstringHelpersTests: XCTestCase {
    
    let string = "12345"
    lazy var characters: [Character] = self.string.characters.filter({ _ in return true })
    lazy var stringLength: Int = self.string.characters.count
    
    func testSubstringBeforeLocationMatchFailure() {
        
        XCTAssertNil(string.substringBeforeLocation(location: 0, afterCharacters: []))
        
        if let (foundString, foundCharacter, foundRange) = string.substringBeforeLocation(location: stringLength, afterCharacters: []) {
            XCTAssertEqual(foundString, string)
            XCTAssertNil(foundCharacter)
            XCTAssertEqual(foundRange, string.startIndex..<string.endIndex)
        } else {
            XCTFail()
        }
        
        if let (foundString, foundCharacter, foundRange) = string.substringBeforeLocation(location: stringLength - 1, afterCharacters: [characters.last!]) {
            XCTAssertEqual(foundString, string.substring(to: string.index(before: string.endIndex)))
            XCTAssertNil(foundCharacter)
            XCTAssertEqual(foundRange, string.startIndex..<string.index(before: string.endIndex))
        } else {
            XCTFail()
        }
    }
    
    func testSubstringBeforeLocationMatchSuccess() {
        
        var matchCharacter = characters.first!
        if let (foundString, foundCharacter, foundRange) = string.substringBeforeLocation(location: stringLength, afterCharacters: [matchCharacter]) {
            XCTAssertEqual(foundString, string.substring(from: string.index(after: string.startIndex)))
            XCTAssertEqual(foundCharacter, matchCharacter)
            XCTAssertEqual(foundRange, string.range(of: foundString))
        } else {
            XCTFail()
        }
        
        if let (foundString, foundCharacter, foundRange) = string.substringBeforeLocation(location: 1, afterCharacters: [matchCharacter]) {
            XCTAssertEqual(foundString, "")
            XCTAssertEqual(foundCharacter, matchCharacter)
            let secondIndex = string.characters.index(after: string.startIndex)
            XCTAssertEqual(foundRange, secondIndex..<secondIndex)
        } else {
            XCTFail()
        }
        
        matchCharacter = characters.last!
        if let (foundString, foundCharacter, foundRange) = string.substringBeforeLocation(location: stringLength, afterCharacters: [matchCharacter]) {
            XCTAssertEqual(foundString, "")
            XCTAssertEqual(foundCharacter, matchCharacter)
            let endIndex = string.endIndex
            XCTAssertEqual(foundRange, endIndex..<endIndex)
        } else {
            XCTFail()
        }
    }
    
    func testSubstringAfterLocationMatchFailure() {
        
        XCTAssertNil(string.substringAfterLocation(location: stringLength, beforeCharacters: []))
        
        if let (foundString, foundCharacter, foundRange) = string.substringAfterLocation(location: 0, beforeCharacters: []) {
            XCTAssertEqual(foundString, string)
            XCTAssertNil(foundCharacter)
            XCTAssertEqual(foundRange, string.startIndex..<string.endIndex)
        } else {
            XCTFail()
        }
        
        if let (foundString, foundCharacter, foundRange) = string.substringAfterLocation(location: 1, beforeCharacters: [characters.first!]) {
            XCTAssertEqual(foundString, string.substring(from: string.index(after: string.startIndex)))
            XCTAssertNil(foundCharacter)
            XCTAssertEqual(foundRange, string.index(after: string.startIndex)..<string.endIndex)
        } else {
            XCTFail()
        }
    }
    
    func testSubstringAfterLocationMatchSuccess() {
        
        var matchCharacter = characters.last!
        if let (foundString, foundCharacter, foundRange) = string.substringAfterLocation(location: 0, beforeCharacters: [matchCharacter]) {
            XCTAssertEqual(foundString, string.substring(to: string.index(before: string.endIndex)))
            XCTAssertEqual(foundCharacter, matchCharacter)
            XCTAssertEqual(foundRange, string.range(of: foundString))
        } else {
            XCTFail()
        }
        
        if let (foundString, foundCharacter, foundRange) = string.substringAfterLocation(location: stringLength - 1, beforeCharacters: [matchCharacter]) {
            XCTAssertEqual(foundString, "")
            XCTAssertEqual(foundCharacter, matchCharacter)
            let secondToLastIndex = string.characters.index(before: string.endIndex)
            XCTAssertEqual(foundRange, secondToLastIndex..<secondToLastIndex)
        } else {
            XCTFail()
        }
        
        matchCharacter = characters.first!
        if let (foundString, foundCharacter, foundRange) = string.substringAfterLocation(location: 0, beforeCharacters: [matchCharacter]) {
            XCTAssertEqual(foundString, "")
            XCTAssertEqual(foundCharacter, matchCharacter)
            let firstIndex = string.startIndex
            XCTAssertEqual(foundRange, firstIndex..<firstIndex)
        } else {
            XCTFail()
        }
    }
}
