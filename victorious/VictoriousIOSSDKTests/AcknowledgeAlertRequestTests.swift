//
//  AcknowledgeAlertRequestTests.swift
//  victorious
//
//  Created by Michael Sena on 11/16/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import XCTest

@testable import VictoriousIOSSDK

class AcknowledgeAlertRequestTests: XCTestCase {

    func testRequest() {        
        let alertID = "1524"
        let acknowledgeAlertRequest = AcknowledgeAlertRequest(alertID: alertID)
        XCTAssertEqual(acknowledgeAlertRequest.urlRequest.URL?.absoluteString, "/api/alert/acknowledge")
        
        guard let bodyData = acknowledgeAlertRequest.urlRequest.HTTPBody else {
            XCTFail("No HTTP Body!")
            return
        }

        let bodyString = String(data: bodyData, encoding: NSUTF8StringEncoding)!
        
        XCTAssertNotNil(bodyString.rangeOfString("alert_id=\(alertID)"))
    }

}
