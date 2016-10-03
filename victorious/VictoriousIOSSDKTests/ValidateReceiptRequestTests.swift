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
        guard  let receiptData = "NSData whose `length` will be > 0 for testing.".data(using: String.Encoding.utf8),
            let request = ValidateReceiptRequest(apiPath: APIPath(templatePath: urlString), data: receiptData) else {
            XCTFail("Error preparing mock input data.")
            return
        }
        
        XCTAssertEqual(request.urlRequest.url, URL(string: urlString))
        XCTAssertEqual(request.urlRequest.HTTPMethod, "POST")
        
        guard let mockUserDataURL = Bundle(for: type(of: self)).url(forResource: "PurchaseResponse", withExtension: "json"),
            let mockData = try? Data(contentsOf: mockUserDataURL) else {
                XCTFail("Error reading mock json data")
                return
        }
        
        do {
            let vipStatus = try request.parseResponse(
                URLResponse(),
                toRequest: URLRequest(),
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
