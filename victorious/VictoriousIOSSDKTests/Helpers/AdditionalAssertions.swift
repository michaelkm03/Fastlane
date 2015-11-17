//
//  AdditionalAssertions.swift
//  victorious
//
//  Created by Tian Lan on 11/17/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import XCTest

/// Asserts that the `block` throws an expected error
func AssertThrows<T: ErrorType where T: Equatable>(error: T, @autoclosure block: () throws -> ()) {
    do {
        try block()
    } catch let e as T {
        XCTAssertEqual(e, error)
    } catch {
        XCTFail("Wrong type of error thrown")
    }
}
