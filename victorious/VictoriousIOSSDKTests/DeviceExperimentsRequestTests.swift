//
//  DeviceExperimentsRequestTests.swift
//  victorious
//
//  Created by Michael Sena on 12/8/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import XCTest
import VictoriousIOSSDK

class DeviceExperimentsRequestTests: XCTestCase {
    
    func testRequest() {
        let experimentSettingsRequest = DeviceExperimentsRequest()
        XCTAssertEqual(experimentSettingsRequest.urlRequest.URL, NSURL(string: "/api/device/experiments"))
    }
    
    func testValidResponseParsing() {
        guard let mockResponseDataURL = NSBundle(forClass: self.dynamicType).URLForResource("DeviceExperimentsResponse", withExtension: "json"), let mockData = NSData(contentsOfURL: mockResponseDataURL) else {
            XCTFail("Error reading mock json data.")
            return
        }
        
        do {
            let request = DeviceExperimentsRequest()
            let (experiments, _) = try request.parseResponse(NSURLResponse(), toRequest: request.urlRequest, responseData: mockData, responseJSON: JSON(data: mockData))
            let firstExperiment = experiments.first!
            XCTAssertEqual(firstExperiment.name, "shelves_variant_0")
        } catch {
            XCTFail("Sorry, parseResponse should not throw here.")
        }
    }
    
}
