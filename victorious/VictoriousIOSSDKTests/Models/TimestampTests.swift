//
//  TimestampTests.swift
//  victorious
//
//  Created by Jarod Long on 7/21/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import VictoriousIOSSDK
import XCTest

class TimestampTests: XCTestCase {
    func testInitializing() {
        XCTAssertEqual(Timestamp(apiString: "123"), Timestamp(value: 123))
        XCTAssertEqual(Timestamp(apiString: "1469053087198"), Timestamp(value: 1469053087198))
        XCTAssertEqual(Timestamp(apiString: "393647482173891275893738912738912738921"), nil)
        XCTAssertEqual(Timestamp(apiString: ""), nil)
        XCTAssertEqual(Timestamp(apiString: "asdf"), nil)
    }
    
    func testAPIString() {
        XCTAssertEqual(Timestamp(apiString: "6891")?.apiString, "6891")
        XCTAssertEqual(Timestamp(apiString: "3218903")?.apiString, "3218903")
    }
    
    func testComparison() {
        XCTAssert(Timestamp(apiString: "5000") == Timestamp(apiString: "5000"))
        XCTAssert(Timestamp(apiString: "5000")! < Timestamp(apiString: "5001")!)
        XCTAssert(Timestamp(apiString: "5001")! > Timestamp(apiString: "5000")!)
    }
    
    func testDateConversion() {
        let date = Date(timeIntervalSince1970: 12345.0)
        let timestamp = Timestamp(date: date as NSDate)
        XCTAssertEqual(timestamp.apiString, "12345000")
        XCTAssertEqualWithAccuracy(Date(timestamp: timestamp).timeIntervalSince1970, date.timeIntervalSince1970, accuracy: 0.01)
    }
}
