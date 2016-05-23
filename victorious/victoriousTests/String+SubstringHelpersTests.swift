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
            XCTAssertTrue(NSEqualRanges(foundRange, NSMakeRange(0, stringLength)))
        } else {
            XCTFail()
        }
        
        if let (foundString, foundCharacter, foundRange) = string.substringBeforeLocation(stringLength - 1, afterCharacters: [characters.last!]) {
            XCTAssertEqual(foundString, (string as NSString).substringToIndex(stringLength - 1))
            XCTAssertNil(foundCharacter)
            XCTAssertTrue(NSEqualRanges(foundRange, NSMakeRange(0, stringLength - 1)))
        } else {
            XCTFail()
        }
    }
    
    func testSubstringBeforeLocationMatchSuccess() {
        
        var matchCharacter = characters.first!
        if let (foundString, foundCharacter, foundRange) = string.substringBeforeLocation(stringLength, afterCharacters: [matchCharacter]) {
            XCTAssertEqual(foundString, (string as NSString).substringFromIndex(1))
            XCTAssertEqual(foundCharacter, matchCharacter)
            XCTAssertTrue(NSEqualRanges(foundRange, (string as NSString).rangeOfString(foundString)))
        } else {
            XCTFail()
        }
        
        if let (foundString, foundCharacter, foundRange) = string.substringBeforeLocation(1, afterCharacters: [matchCharacter]) {
            XCTAssertEqual(foundString, "")
            XCTAssertEqual(foundCharacter, matchCharacter)
            XCTAssertTrue(NSEqualRanges(foundRange, NSMakeRange(1, 0)))
        } else {
            XCTFail()
        }
        
        matchCharacter = characters.last!
        if let (foundString, foundCharacter, foundRange) = string.substringBeforeLocation(stringLength, afterCharacters: [matchCharacter]) {
            XCTAssertEqual(foundString, "")
            XCTAssertEqual(foundCharacter, matchCharacter)
            XCTAssertTrue(NSEqualRanges(foundRange, NSMakeRange(stringLength, 0)))
        } else {
            XCTFail()
        }
    }
    
    func testSubstringAfterLocationMatchFailure() {
        
        XCTAssertNil(string.substringAfterLocation(stringLength, beforeCharacters: []))
        
        if let (foundString, foundCharacter, foundRange) = string.substringAfterLocation(-1, beforeCharacters: []) {
            XCTAssertEqual(foundString, string)
            XCTAssertNil(foundCharacter)
            XCTAssertTrue(NSEqualRanges(foundRange, NSMakeRange(0, stringLength)))
        } else {
            XCTFail()
        }
        
        if let (foundString, foundCharacter, foundRange) = string.substringAfterLocation(0, beforeCharacters: [characters.first!]) {
            XCTAssertEqual(foundString, (string as NSString).substringFromIndex(1))
            XCTAssertNil(foundCharacter)
            XCTAssertTrue(NSEqualRanges(foundRange, NSMakeRange(1, stringLength - 1)))
        } else {
            XCTFail()
        }
    }
    
    func testSubstringAfterLocationMatchSuccess() {
        
        var matchCharacter = characters.last!
        if let (foundString, foundCharacter, foundRange) = string.substringAfterLocation(-1, beforeCharacters: [matchCharacter]) {
            XCTAssertEqual(foundString, (string as NSString).substringToIndex(stringLength - 1))
            XCTAssertEqual(foundCharacter, matchCharacter)
            XCTAssertTrue(NSEqualRanges(foundRange, (string as NSString).rangeOfString(foundString)))
        } else {
            XCTFail()
        }
        
        if let (foundString, foundCharacter, foundRange) = string.substringAfterLocation(stringLength - 2, beforeCharacters: [matchCharacter]) {
            XCTAssertEqual(foundString, "")
            XCTAssertEqual(foundCharacter, matchCharacter)
            XCTAssertTrue(NSEqualRanges(foundRange, NSMakeRange(stringLength - 1, 0)))
        } else {
            XCTFail()
        }
        
        matchCharacter = characters.first!
        if let (foundString, foundCharacter, foundRange) = string.substringAfterLocation(-1, beforeCharacters: [matchCharacter]) {
            XCTAssertEqual(foundString, "")
            XCTAssertEqual(foundCharacter, matchCharacter)
            XCTAssertTrue(NSEqualRanges(foundRange, NSMakeRange(0, 0)))
        } else {
            XCTFail()
        }
    }
}
