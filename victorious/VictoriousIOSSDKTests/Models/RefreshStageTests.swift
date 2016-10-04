//
//  RefreshStageTests.swift
//  victorious
//
//  Created by Sebastian Nystorm on 31/3/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import XCTest
@testable import VictoriousIOSSDK

class RefreshStageTests: XCTestCase {

    func testVIPInitialization() {
        guard let refreshStageVIPJSONURL = Bundle(for: type(of: self)).url(forResource: "RefreshStageVIP", withExtension: "json"),
            let jsonData = try? Data(contentsOf: refreshStageVIPJSONURL) else {
                XCTFail("Error reading RefreshStage JSON data.")
                return
        }
        let serverTime = Timestamp(value: 1234567890000)
        guard let refreshStage = RefreshStage(json: JSON(data: jsonData), serverTime: serverTime) else {
            XCTFail("RefreshStage initializer failed.")
            return
        }
        
        XCTAssertEqual(refreshStage.contentID, "BB7670057")
        XCTAssertEqual(refreshStage.section, StageSection.vip)
        XCTAssertEqual(refreshStage.serverTime, serverTime)
    }
    
    func testMainInitialization() {
        guard let refreshStageMainJSONURL = Bundle(for: type(of: self)).url(forResource: "RefreshStageMain", withExtension: "json"),
            let jsonData = try? Data(contentsOf: refreshStageMainJSONURL) else {
                XCTFail("Error reading RefreshStage JSON data.")
                return
        }
        let serverTime = Timestamp(value: 1234567890000)
        guard let refreshStage = RefreshStage(json: JSON(data: jsonData), serverTime: serverTime) else {
            XCTFail("RefreshStage initializer failed.")
            return
        }
        
        XCTAssertEqual(refreshStage.contentID, "XBXBX8888")
        XCTAssertEqual(refreshStage.section, StageSection.main)
        XCTAssertEqual(refreshStage.serverTime, serverTime)
    }
}
