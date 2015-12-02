//
//  GIFSearchOperationTests.swift
//  victorious
//
//  Created by Tian Lan on 11/30/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import XCTest
import VictoriousIOSSDK
import SwiftyJSON
@testable import victorious

class GIFSearchOperationTests: XCTestCase {
    
    func testOnComplete() {
        guard let mockResponseDataURL = NSBundle(forClass: self.dynamicType).URLForResource("GIFSearchResponse", withExtension: "json"),
            let mockData = NSData(contentsOfURL: mockResponseDataURL) else {
                XCTFail("Error reading mock json data")
                return
        }
        
        do {
            let request = GIFSearchRequest(searchTerm: "lol")
            let result: ([VictoriousIOSSDK.GIFSearchResult], GIFSearchRequest?, GIFSearchRequest?) = try request.parseResponse(NSURLResponse(), toRequest: request.urlRequest, responseData: mockData, responseJSON: JSON(data: mockData))
            let gifSearchOperation = GIFSearchOperation(request: request)
            gifSearchOperation.onComplete(result){ }
            XCTAssertEqual(gifSearchOperation.searchResults.count, 15)
            XCTAssertNotNil(gifSearchOperation.nextPageOperation)
            XCTAssertNil(gifSearchOperation.previousPageOperation)
        } catch {
            XCTFail("Sorry, parseResponse should not throw here")
        }
    }
}
