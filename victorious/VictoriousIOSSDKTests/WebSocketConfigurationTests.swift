//
//  WebSocketConfigurationTests.swift
//  victorious
//
//  Created by Sebastian Nystorm on 25/3/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import XCTest
@testable import VictoriousIOSSDK

class WebSocketConfigurationTests : XCTestCase {
    
    func testFailedConfiguration() {
        let brokenUrlString = "$%^&*"
        let configuration = WebSocketConfiguration(endPoint: brokenUrlString, port: UInt(1), serviceVersion: "1", forceDisconnectTimeout: 1, appId: "1")
        XCTAssertNil(configuration, "Expected WebSocketConfiguration to fail to initialize beacuse of broken URL string.")
    }
    
    func testConfigurationCreation() {
        let endPoint = "ws://test.com"
        let port: UInt = 1337
        let serviceVersion = "v90"
        let forceDisconnect: NSTimeInterval = 66
        let appId = "666"
        
        let urlString = "\(endPoint):\(port)"
        var url = NSURL(string: urlString)
        url = url!.URLByAppendingPathComponent(serviceVersion)
        url = url!.URLByAppendingPathComponent(appId)
        
        let configuration = WebSocketConfiguration(endPoint: endPoint, port: port, serviceVersion: serviceVersion, forceDisconnectTimeout: forceDisconnect, appId: appId)
        
        XCTAssertNotNil(configuration, "Expected WebSocketConfiguration to be initialized.")
        XCTAssertEqual(configuration!.endPoint, endPoint, "Expected endpoint to be the same.")
        XCTAssertEqual(configuration!.port, port, "Expected port to be the same.")
        XCTAssertEqual(configuration!.serviceVersion, serviceVersion, "Expected serviceVersion to be the same.")
        XCTAssertEqual(configuration!.forceDisconnectTimeout, forceDisconnect, "Expected forceDisconnect to be the same.")
        XCTAssertEqual(configuration!.appId, appId, "Expected appId to be the same.")
        XCTAssertEqual(configuration!.baseUrl, url, "Expected that a similar URL be created with the configuration.")
        
        let configurationUrl = WebSocketConfiguration(endPoint: "ws://test.com", port: UInt(10), serviceVersion: "v1", forceDisconnectTimeout: 1, appId: "9000")
        XCTAssertNotNil(configurationUrl, "Expected WebSocketConfiguration to be initialized.")
        XCTAssertEqual(configurationUrl!.baseUrl.absoluteString, "ws://test.com:10/v1/9000", "Expected the absolute URL string to be equal.")
        
        let configurationWSSUrl = WebSocketConfiguration(endPoint: "wss://test.com", port: UInt(1000), serviceVersion: "v1", forceDisconnectTimeout: 1, appId: "9000")
        XCTAssertNotNil(configurationWSSUrl, "Expected WebSocketConfiguration to be initialized.")
        XCTAssertEqual(configurationWSSUrl!.baseUrl.absoluteString, "wss://test.com:1000/v1/9000", "Expected the absolute URL string to be equal.")
    }
}
