//
//  GIFSearchResultTests.swift
//  victorious
//
//  Created by Cody Kolodziejzyk on 11/9/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import VictoriousIOSSDK
import XCTest

class GIFSearchResultTests: XCTestCase {
    
    func testJSONParsing() {
        guard let mockUserDataURL = Bundle(for: type(of: self)).url(forResource: "GIFSearchResult", withExtension: "json"),
            let mockData = try? Data(contentsOf: mockUserDataURL) else {
                XCTFail("Error reading mock json data")
                return
        }
        guard let gifSearchResult = GIFSearchResult(json: JSON(data: mockData)) else {
            XCTFail("User initializer failed")
            return
        }
        XCTAssertEqual(gifSearchResult.gifURL, "https://media2.giphy.com/media/KxufLEowgK7Xa/giphy.gif")
        XCTAssertEqual(gifSearchResult.gifSize, 1765032)
        XCTAssertEqual(gifSearchResult.mp4URL, "https://media2.giphy.com/media/KxufLEowgK7Xa/giphy.mp4")
        XCTAssertEqual(gifSearchResult.mp4Size, 72987)
        XCTAssertEqual(gifSearchResult.frames, 10)
        XCTAssertEqual(gifSearchResult.width, 500)
        XCTAssertEqual(gifSearchResult.height, 500)
        XCTAssertEqual(gifSearchResult.thumbnailURL, "https://media2.giphy.com/media/KxufLEowgK7Xa/100.gif")
        XCTAssertEqual(gifSearchResult.thumbnailStillURL, "https://media2.giphy.com/media/KxufLEowgK7Xa/100_s.gif")
        XCTAssertEqual(gifSearchResult.remoteID, "KxufLEowgK7Xa")
    }
}
