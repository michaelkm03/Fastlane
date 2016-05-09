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
        guard  let receiptData = "NSData whose `length` will be > 0 for testing.".dataUsingEncoding(NSUTF8StringEncoding),
            let request = ValidateReceiptRequest(data: receiptData) else {
            XCTFail("Error preparing mock input data.")
            return
        }
        
        XCTAssertEqual(request.urlRequest.URL, NSURL(string: "/api/purchase") )
        XCTAssertEqual(request.urlRequest.HTTPMethod, "POST" )
        
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
            
            guard let vipEndDate = vipStatus.endDate else {
                XCTFail("Although the `endDate` property is optional, in this test we are expecting it to be parsed.")
                return
            }
            
            XCTAssertEqual(vipStatus.isVIP, true)
            let dateFormatter = NSDateFormatter(vsdk_format: .Standard)
            XCTAssertEqual(dateFormatter.stringFromDate(vipEndDate), "2016-05-02 18:22:50")
            
        } catch {
            XCTFail("Failed to parse response to `ValidateReceiptRequest`.")
            return
        }
    }
}
