//
//  CreatorListRequestTests.swift
//  victorious
//
//  Created by Tian Lan on 4/22/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import XCTest
@testable import VictoriousIOSSDK

class CreatorListRequestTests: XCTestCase {
    
    private let urlFromTemplate = "https://vapi-dev.getvictorious.com/v1/user/owners/"
    
    func testInitialization() {
        let request = CreatorListRequest(urlString: urlFromTemplate)
        XCTAssertNotNil(request)
        
        let expectedURLString = "https://vapi-dev.getvictorious.com/v1/user/owners/"
        let expectedURL = NSURL(string: expectedURLString)!
        
        XCTAssertEqual(expectedURL, request.urlRequest.URL)
        XCTAssertEqual(expectedURL.baseURL, request.baseURL)
    }
    
    func testResponseParsing() {
        guard let mockResponseDataURL = NSBundle(forClass: self.dynamicType).URLForResource("SequenceLikersResponse", withExtension: "json"),
            let mockData = NSData(contentsOfURL: mockResponseDataURL) else {
                XCTFail("Error reading mock json data")
                return
        }
        
        do {
            let request = CreatorListRequest(urlString: urlFromTemplate)
            let results = try request.parseResponse(NSURLResponse(), toRequest: request.urlRequest, responseData: mockData, responseJSON: JSON(data: mockData))
            
            XCTAssertEqual(results.count, 3)
            
            XCTAssertEqual(results.first?.userID, 405130)
            XCTAssertEqual(results.first?.name, "Sabs")
            
            XCTAssertEqual(results.last?.userID, 643629)
            XCTAssertEqual(results.last?.name, "Lilith_Arianna")
        } catch {
            XCTFail("Sorry, parseResponse should not throw here")
        }
    }
}
