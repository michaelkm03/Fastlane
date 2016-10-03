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
        
        XCTAssertNil(string.substringBeforeLocation(0, afterCharacters: []))
        
        if let (foundString, foundCharacter, foundRange) = string.substringBeforeLocation(stringLength, afterCharacters: []) {
            XCTAssertEqual(foundString, string)
            XCTAssertNil(foundCharacter)
            XCTAssertEqual(foundRange, string.startIndex..<string.endIndex)
        } else {
            XCTFail()
        }
        
        if let (foundString, foundCharacter, foundRange) = string.substringBeforeLocation(stringLength - 1, afterCharacters: [characters.last!]) {
            XCTAssertEqual(foundString, string.substringToIndex(string.endIndex.predecessor()))
            XCTAssertNil(foundCharacter)
            XCTAssertEqual(foundRange, string.startIndex..<string.endIndex.predecessor())
        } else {
            XCTFail()
        }
    }
    
    func testSubstringBeforeLocationMatchSuccess() {
        
        var matchCharacter = characters.first!
        if let (foundString, foundCharacter, foundRange) = string.substringBeforeLocation(stringLength, afterCharacters: [matchCharacter]) {
            XCTAssertEqual(foundString, string.substringFromIndex(string.startIndex.successor()))
            XCTAssertEqual(foundCharacter, matchCharacter)
            XCTAssertEqual(foundRange, string.rangeOfString(foundString))
        } else {
            XCTFail()
        }
        
        if let (foundString, foundCharacter, foundRange) = string.substringBeforeLocation(1, afterCharacters: [matchCharacter]) {
            XCTAssertEqual(foundString, "")
            XCTAssertEqual(foundCharacter, matchCharacter)
            let secondIndex = string.characters.index(after: string.startIndex)
            XCTAssertEqual(foundRange, secondIndex..<secondIndex)
        } else {
            XCTFail()
        }
        
        matchCharacter = characters.last!
        if let (foundString, foundCharacter, foundRange) = string.substringBeforeLocation(stringLength, afterCharacters: [matchCharacter]) {
            XCTAssertEqual(foundString, "")
            XCTAssertEqual(foundCharacter, matchCharacter)
            let endIndex = string.endIndex
            XCTAssertEqual(foundRange, endIndex..<endIndex)
        } else {
            XCTFail()
        }
    }
    
    func testSubstringAfterLocationMatchFailure() {
        
        XCTAssertNil(string.substringAfterLocation(stringLength, beforeCharacters: []))
        
        if let (foundString, foundCharacter, foundRange) = string.substringAfterLocation(0, beforeCharacters: []) {
            XCTAssertEqual(foundString, string)
            XCTAssertNil(foundCharacter)
            XCTAssertEqual(foundRange, string.startIndex..<string.endIndex)
        } else {
            XCTFail()
        }
        
        if let (foundString, foundCharacter, foundRange) = string.substringAfterLocation(1, beforeCharacters: [characters.first!]) {
            XCTAssertEqual(foundString, string.substringFromIndex(string.startIndex.successor()))
            XCTAssertNil(foundCharacter)
            XCTAssertEqual(foundRange, string.startIndex.successor()..<string.endIndex)
        } else {
            XCTFail()
        }
    }
    
    func testSubstringAfterLocationMatchSuccess() {
        
        var matchCharacter = characters.last!
        if let (foundString, foundCharacter, foundRange) = string.substringAfterLocation(0, beforeCharacters: [matchCharacter]) {
            XCTAssertEqual(foundString, string.substringToIndex(string.endIndex.predecessor()))
            XCTAssertEqual(foundCharacter, matchCharacter)
            XCTAssertEqual(foundRange, string.rangeOfString(foundString))
        } else {
            XCTFail()
        }
        
        if let (foundString, foundCharacter, foundRange) = string.substringAfterLocation(stringLength - 1, beforeCharacters: [matchCharacter]) {
            XCTAssertEqual(foundString, "")
            XCTAssertEqual(foundCharacter, matchCharacter)
            let secondToLastIndex = string.characters.index(before: string.endIndex)
            XCTAssertEqual(foundRange, secondToLastIndex..<secondToLastIndex)
        } else {
            XCTFail()
        }
        
        matchCharacter = characters.first!
        if let (foundString, foundCharacter, foundRange) = string.substringAfterLocation(0, beforeCharacters: [matchCharacter]) {
            XCTAssertEqual(foundString, "")
            XCTAssertEqual(foundCharacter, matchCharacter)
            let firstIndex = string.startIndex
            XCTAssertEqual(foundRange, firstIndex..<firstIndex)
        } else {
            XCTFail()
        }
    }
}
