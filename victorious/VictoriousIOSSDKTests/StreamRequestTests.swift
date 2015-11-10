//
//  StreamRequestTests.swift
//  victorious
//
//  Created by Patrick Lynch on 11/9/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import SwiftyJSON
@testable import VictoriousIOSSDK
import XCTest

class StreamRequestTests: XCTestCase {
    
    let apiPath = "/api/sample/stream"
    
    func testRequest() {
        
        var request: StreamRequest
        
        request = StreamRequest(apiPath: apiPath)
        XCTAssertEqual( request.paginator.pageNumber, 1 )
        XCTAssertEqual( request.paginator.itemsPerPage, 15 )
        XCTAssertEqual( request.urlRequest.URL!.absoluteString, apiPath + "/1/15" )
        
        let pageNumber = 2
        let itemsPerPage = 20
        request = StreamRequest(apiPath: apiPath, pageNumber: pageNumber, itemsPerPage: itemsPerPage)
        XCTAssertEqual( request.paginator.pageNumber, pageNumber )
        XCTAssertEqual( request.paginator.itemsPerPage, itemsPerPage )
        
        let requestPath = request.urlRequest.URL!.absoluteString
        XCTAssertEqual( requestPath, apiPath + "/\(pageNumber)/\(itemsPerPage)" )
    }
    
    func testParseResponse() {
        
        guard let mockUserDataURL = NSBundle(forClass: self.dynamicType).URLForResource("StreamResponse", withExtension: "json"),
            let mockData = NSData(contentsOfURL: mockUserDataURL) else {
                XCTFail("Error reading mock json data")
                return
        }
        
        var request = StreamRequest(apiPath: apiPath)
        do {
            var output = try request.parseResponse(NSURLResponse(), toRequest: NSURLRequest(), responseData: mockData, responseJSON: JSON(data: mockData))
            XCTAssertNotNil( output.results )
            XCTAssertNotNil( output.nextPage )
            XCTAssertNil( output.previousPage )
            
            request = output.nextPage!
            output = try request.parseResponse(NSURLResponse(), toRequest: NSURLRequest(), responseData: mockData, responseJSON: JSON(data: mockData))
            XCTAssertNotNil( output.results )
            XCTAssertNotNil( output.nextPage )
            XCTAssertNotNil( output.previousPage )
        } catch {
            XCTFail("parseResponse is not supposed to throw")
        }
    }
}
