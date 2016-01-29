//
//  AdBreakTests.swift
//  victorious
//
//  Created by Alex Tamoykin on 1/23/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import XCTest
import SwiftyJSON
@testable import VictoriousIOSSDK

class AdBreakTests: XCTestCase {
    let expectedTestAdTag = "https://pubads.g.doubleclick.net/gampad/ads?sz=640x480&iu=/124319096/external/ad_rule_samples" +
        "&ciu_szs=300x250&ad_rule=1&impl=s&gdfp_req=1&env=vp&output=vmap&unviewed_position_start=1" +
    "&cust_params=deployment%3Ddevsite%26sample_ar%3Dpreonly&cmsid=496&vid=short_onecue&correlator="

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }

    func testValid() {
        guard let adBreakWithEverything = createAdBreakFromJSON(fileName: "AdBreakWithEverything") else {
            XCTFail("Failed to create an adBreak")
            return
        }
        XCTAssertEqual(5, adBreakWithEverything.adSystemID)
        XCTAssertEqual(7000, adBreakWithEverything.timeout)
        XCTAssertEqual(expectedTestAdTag, adBreakWithEverything.adTag)
        XCTAssertEqual("test_xml", adBreakWithEverything.cannedAdXML)

        guard let adBreakWithOnlyAdTag = createAdBreakFromJSON(fileName: "AdBreakWithOnlyAdTag") else {
            XCTFail("Failed to create an adBreak")
            return
        }
        XCTAssertEqual(5, adBreakWithOnlyAdTag.adSystemID)
        XCTAssertEqual(7000, adBreakWithOnlyAdTag.timeout)
        XCTAssertEqual(expectedTestAdTag, adBreakWithOnlyAdTag.adTag)
        XCTAssertEqual("", adBreakWithOnlyAdTag.cannedAdXML)

        guard let adBreakWithOnlyCannedXML = createAdBreakFromJSON(fileName: "AdBreakWithOnlyCannedXML") else {
            XCTFail("Failed to create an adBreak")
            return
        }
        XCTAssertEqual(5, adBreakWithOnlyCannedXML.adSystemID)
        XCTAssertEqual(7000, adBreakWithOnlyCannedXML.timeout)
        XCTAssertEqual("", adBreakWithOnlyCannedXML.adTag)
        XCTAssertEqual("test_xml", adBreakWithOnlyCannedXML.cannedAdXML)
    }

    func testInvalid() {
        let adBreakWithoutTimeout: AdBreak? = createAdBreakFromJSON(fileName: "AdBreakWithoutTimeout")
        XCTAssertNil(adBreakWithoutTimeout)
        let adBreakWithoutAdTagAndCannedAdXML: AdBreak? = createAdBreakFromJSON(fileName: "AdBreakWithoutAdTagAndCannedAdXML")
        XCTAssertNil(adBreakWithoutAdTagAndCannedAdXML)
    }

    private func createAdBreakFromJSON(fileName fileName: String) -> AdBreak? {
        guard let url = NSBundle(forClass: self.dynamicType).URLForResource(fileName, withExtension: "json") else {
            XCTFail("Failed to find mock data with name \(fileName).json")
            return nil
        }

        guard let adBreak = AdBreak(url: url) else {
            return nil
        }

        return adBreak
    }
}
