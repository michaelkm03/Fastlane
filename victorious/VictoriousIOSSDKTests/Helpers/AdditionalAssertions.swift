//
//  AdditionalAssertions.swift
//  victorious
//
//  Created by Tian Lan on 11/17/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import XCTest

/// Asserts that the `expression` throws a specific error
func assertThrowsSpecific<T: Error>(_ expression: @autoclosure () throws -> Any, _ error: T) {
    var didThrow = false
    do {
        try expression()
    } catch _ as T {
        didThrow = true
    } catch {
        XCTFail("Wrong type of error thrown")
        didThrow = true
    }
    XCTAssertTrue(didThrow)
}

/// Asserts that the `expression` throws any error
func assertThrows(_ expression: @autoclosure () throws -> Any) {
    var didThrow = false
    do {
        try expression()
    } catch {
        didThrow = true
    }
    XCTAssertTrue(didThrow)
}
