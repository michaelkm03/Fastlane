//
//  ValidateReceiptRequestTests.swift
//  victorious
//
//  Created by Patrick Lynch on 5/2/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import XCTest
@testable import VictoriousIOSSDK

class ValidateReceiptRequestTests: XCTestCase {
    func testParseResponse() {
        let urlString = "urlString"
        guard  let receiptData = "NSData whose `length` will be > 0 for testing.".dataUsingEncoding(NSUTF8StringEncoding),
            let request = ValidateReceiptRequest(apiPath: APIPath(templatePath: urlString), data: receiptData) else {
            XCTFail("Error preparing mock input data.")
            return
        }
        
        XCTAssertEqual(request.urlRequest.URL, NSURL(string: urlString))
        XCTAssertEqual(request.urlRequest.HTTPMethod, "POST")
        
        guard let mockUserDataURL = NSBundle(forClass: self.dynamicType).URLForResource("PurchaseResponse", withExtension: "json"),
            let mockData = NSData(contentsOfURL: mockUserDataURL) else {
                XCTFail("Error reading mock json data")
                return
        }
        
        do {
            let vipStatus = try request.parseResponse(
                NSURLResponse(),
                toRequest: NSURLRequest(),
                responseData: mockData,
                responseJSON: JSON(data: mockData)
            )
            
            XCTAssertEqual(vipStatus.isVIP, true)
        } catch {
            XCTFail("Failed to parse response to `ValidateReceiptRequest`.")
            return
        }
    }
}
