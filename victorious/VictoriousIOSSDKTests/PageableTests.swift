//
//  PageableTests.swift
//  victorious
//
//  Created by Josh Hinman on 11/1/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import SwiftyJSON
import VictoriousIOSSDK
import XCTest

private let headerField = "Coal-Mine"
private let headerValue = "paginated canary"

private let nextPage = 10
private let previousPage = 20
private let result = "😎"

private struct MockPaginator: PaginatorType {
    func paginatedRequestWithRequest(request: NSURLRequest) -> NSURLRequest {
        let mutableRequest = request.mutableCopy() as! NSMutableURLRequest
        mutableRequest.setValue(headerValue, forHTTPHeaderField: headerField)
        return mutableRequest
    }
    
    func parsePageInformationFromResponse(response: NSURLResponse, toRequest request: NSURLRequest, responseData: NSData, responseJSON: JSON) -> (nextPage: Int?, previousPage: Int?) {
        return (nextPage, previousPage)
    }
}

private struct MockPageable: Pageable {
    let paginator = MockPaginator()
    
    var pageableURLRequest: NSURLRequest {
        return NSURLRequest()
    }
    
    func parsePageableResponse( response: NSURLResponse, toRequest request: NSURLRequest, responseData: NSData, responseJSON: JSON ) throws -> String {
        return result
    }
}

class PageableTests: XCTestCase {

    /// Tests that the `Pageable` protocol extension properly modifies the urlRequest by delegating to a `PaginatorType`
    func testPageableURL() {
        let pageable = MockPageable()
        let urlRequest = pageable.urlRequest
        XCTAssertEqual(urlRequest.allHTTPHeaderFields?[headerField], headerValue)
    }
    
    func testContinuation() {
        let pageable = MockPageable()
        let actualResult = try! pageable.parseResponse(NSURLResponse(), toRequest: pageable.urlRequest, responseData: NSData(), responseJSON: JSON(NSNull()))
        XCTAssertEqual(actualResult.results, result)
        XCTAssertEqual(actualResult.nextPage, nextPage)
        XCTAssertEqual(actualResult.previousPage, previousPage)
    }
}
