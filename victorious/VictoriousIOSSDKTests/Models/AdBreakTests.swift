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
    let modelHelper = ModelHelper()
    let expectedTestAdTag = "https://pubads.g.doubleclick.net/gampad/ads?sz=640x480&iu=/124319096/external/ad_rule_samples" +
        "&ciu_szs=300x250&ad_rule=1&impl=s&gdfp_req=1&env=vp&output=vmap&unviewed_position_start=1" +
    "&cust_params=deployment%3Ddevsite%26sample_ar%3Dpreonly&cmsid=496&vid=short_onecue&correlator="

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }

    func testValid() {
        guard let adBreakWithEverything: AdBreak = modelHelper.createModel(JSONFileName: "AdBreakWithEverything") else { return }
        XCTAssertEqual(5, adBreakWithEverything.adSystemID)
        XCTAssertEqual(7000, adBreakWithEverything.timeout)
        XCTAssertEqual(expectedTestAdTag, adBreakWithEverything.adTag)
        XCTAssertEqual("test_xml", adBreakWithEverything.cannedAdXML)

        guard let adBreakWithOnlyAdTag: AdBreak = modelHelper.createModel(JSONFileName: "AdBreakWithOnlyAdTag") else { return }
        XCTAssertEqual(5, adBreakWithOnlyAdTag.adSystemID)
        XCTAssertEqual(7000, adBreakWithOnlyAdTag.timeout)
        XCTAssertEqual(expectedTestAdTag, adBreakWithOnlyAdTag.adTag)
        XCTAssertEqual("", adBreakWithOnlyAdTag.cannedAdXML)

        guard let adBreakWithOnlyCannedXML: AdBreak = modelHelper.createModel(JSONFileName: "AdBreakWithOnlyCannedXML") else { return }
        XCTAssertEqual(5, adBreakWithOnlyCannedXML.adSystemID)
        XCTAssertEqual(7000, adBreakWithOnlyCannedXML.timeout)
        XCTAssertEqual("", adBreakWithOnlyCannedXML.adTag)
        XCTAssertEqual("test_xml", adBreakWithOnlyCannedXML.cannedAdXML)
    }

    func testInvalid() {
        let adBreakWithoutAdSystemID: AdBreak? = modelHelper.createModel(JSONFileName: "AdBreakWithoutAdSystemID")
        XCTAssertNil(adBreakWithoutAdSystemID)
        let adBreakWithoutTimeout: AdBreak? = modelHelper.createModel(JSONFileName: "AdBreakWithoutTimeout")
        XCTAssertNil(adBreakWithoutTimeout)
        let adBreakWithoutAdTagAndCannedAdXML: AdBreak? = modelHelper.createModel(JSONFileName: "AdBreakWithoutAdTagAndCannedAdXML")
        XCTAssertNil(adBreakWithoutAdTagAndCannedAdXML)
    }
}
