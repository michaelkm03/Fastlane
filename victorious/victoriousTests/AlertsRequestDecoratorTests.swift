//
//  AlertsRequestDecoratorTests.swift
//  victorious
//
//  Created by Josh Hinman on 1/24/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

@testable import victorious
import VictoriousIOSSDK
import XCTest

class AlertsRequestDecoratorTests: XCTestCase {

    let innerRequest = OneWayRequest(url: NSURL(string: "http://www.example.com/")!)
    var alertsRequest: AlertsRequestDecorator<OneWayRequest>!
    
    override func setUp() {
        super.setUp()
        alertsRequest = AlertsRequestDecorator(request: innerRequest)
    }
    
    func testRequest() {
        XCTAssertEqual(innerRequest.urlRequest, alertsRequest.urlRequest)
    }
    
    func testAlertParsing() {
        guard let mockResponseDataURL = NSBundle(forClass: self.dynamicType).URLForResource("alerts", withExtension: "json"),
            let mockData = NSData(contentsOfURL: mockResponseDataURL) else {
                XCTFail("Error reading mock json data")
                return
        }
        
        do {
            let request = alertsRequest.urlRequest
            let result = try alertsRequest.parseResponse(NSURLResponse(), toRequest: request, responseData: mockData, responseJSON: JSON(data: mockData))
            
            continueAfterFailure = false
            XCTAssertEqual(result.alerts.count, 1)
            XCTAssertEqual(result.alerts[0].alertID, "2475")
            
        } catch {
            XCTFail("Sorry, parseResponse should not throw here")
        }
    }
}
