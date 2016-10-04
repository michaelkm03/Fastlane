//
//  WebSocketErrorTests.swift
//  victorious
//
//  Created by Sebastian Nystorm on 29/6/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import XCTest
@testable import VictoriousIOSSDK

class WebSocketErrorTests: XCTestCase {

    func testInitializationOfBackendErrorCodes() {
        guard let webSocketErrorsJSONPath = Bundle(for: type(of: self)).url(forResource: "WebSocketErrors", withExtension: "json"),
            let jsonData = try? Data(contentsOf: webSocketErrorsJSONPath) else {
                XCTFail("Error reading WebSocketErrors JSON data.")
                return
        }

        let json = JSON(data: jsonData)
        if let jsonErrorMessages = json.array {
            let errorMessages: [WebSocketError] = jsonErrorMessages.flatMap {
                return WebSocketError(json: $0, didDisconnect: false)
            }

            XCTAssertEqual(errorMessages.count, 5)
            XCTAssertTrue(errorMessages[0] == .missingAppId(message: "Message 1"))
            XCTAssertTrue(errorMessages[1] == .missingToken(message: "Message 2"))
            XCTAssertTrue(errorMessages[2] == .unsupportedApp(message: "Message 3"))
            XCTAssertTrue(errorMessages[3] == .unrecognizedToken(message: "Message 4"))
            XCTAssertTrue(errorMessages[4] == .unsupportedProtocol(message: "Message 5"))
        } else {
            XCTFail("Initialization of WebSocketErrors failed.")
        }
    }

    func testDisconnectedErrorInitialization() {
        let disconnectErrorCode = 1337
        let disconnectErrorMessage = "Too c00l to connect"

        let disconnectErrorJSON = JSON(["code": disconnectErrorCode, "message": disconnectErrorMessage])
        let disconnectedError = WebSocketError(json: disconnectErrorJSON, didDisconnect: true)

        XCTAssertNotNil(disconnectedError)
        XCTAssertEqual(disconnectedError, .connectionTerminated(code: disconnectErrorCode, message: disconnectErrorMessage))
    }
}

