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
    
    let streamAPIPath = "http://dev.getvictorious.com/api/sequence/feed/following/%%PAGE_NUM%%/%%ITEMS_PER_PAGE%%"
    
    let streamWithSequenceAPIPath = "http://dev.getvictorious.com/api/sequence/detail_list_by_stream_with_marquee/%%SEQUENCE_ID%%/0/%%PAGE_NUM%%/%%ITEMS_PER_PAGE%%"
    
    func testSimpleStreamRequest() {
        
        var request = StreamRequest( apiPath: streamAPIPath)
        XCTAssertEqual( request.urlRequest.URL?.absoluteString, "http://dev.getvictorious.com/api/sequence/feed/following/1/15" )
        
        let pageNumber = 2
        let itemsPerPage = 20
        request = StreamRequest(apiPath: streamAPIPath, sequenceID: nil, pageNumber: pageNumber, itemsPerPage: itemsPerPage)
        XCTAssertEqual( request.urlRequest.URL?.absoluteString, "http://dev.getvictorious.com/api/sequence/feed/following/\(pageNumber)/\(itemsPerPage)" )
    }
    
    func testComplexStreamRequest() {
        
        let sequenceID = "321321"
        var request = StreamRequest( apiPath: streamWithSequenceAPIPath, sequenceID: sequenceID )
        XCTAssertEqual( request.urlRequest.URL?.absoluteString, "http://dev.getvictorious.com/api/sequence/detail_list_by_stream_with_marquee/\(sequenceID)/0/1/15" )
        
        let pageNumber = 2
        let itemsPerPage = 20
        request = StreamRequest(apiPath: streamWithSequenceAPIPath, sequenceID: sequenceID, pageNumber: pageNumber, itemsPerPage: itemsPerPage)
        XCTAssertEqual( request.urlRequest.URL?.absoluteString,  "http://dev.getvictorious.com/api/sequence/detail_list_by_stream_with_marquee/\(sequenceID)/0/\(pageNumber)/\(itemsPerPage)" )
    }
    
    func testParseResponse() {
        
        guard let mockUserDataURL = NSBundle(forClass: self.dynamicType).URLForResource("StreamResponse", withExtension: "json"),
            let mockData = NSData(contentsOfURL: mockUserDataURL) else {
                XCTFail("Error reading mock json data")
                return
        }
        
        var request = StreamRequest(apiPath: streamAPIPath)
        do {
            var stream = try request.parseResponse(NSURLResponse(), toRequest: NSURLRequest(), responseData: mockData, responseJSON: JSON(data: mockData))
            XCTAssertNotNil( stream )
            XCTAssertNotNil( request.nextPageRequest )
            XCTAssertNil( request.previousPageRequest )
            
            request = request.nextPageRequest!
            stream = try request.parseResponse(NSURLResponse(), toRequest: NSURLRequest(), responseData: mockData, responseJSON: JSON(data: mockData))
            XCTAssertNotNil( stream )
            XCTAssertNotNil( request.nextPageRequest )
            XCTAssertNotNil( request.previousPageRequest )
        } catch {
            XCTFail("parseResponse is not supposed to throw")
        }
    }
}
