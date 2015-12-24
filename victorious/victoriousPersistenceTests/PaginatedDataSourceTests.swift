//
//  PaginatedDataSourceTests.swift
//  victorious
//
//  Created by Patrick Lynch on 12/23/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import XCTest
@testable import victorious
import VictoriousIOSSDK

private let numberOfPagesBeforeReadingEnd = 5

struct MockPaginatedRequest: PaginatorPageable, ResultBasedPageable {
    
    let paginator: StandardPaginator
    var urlRequest = NSURLRequest()
    
    init( paginator: StandardPaginator = StandardPaginator(pageNumber: 1, itemsPerPage: 20) ) {
        self.paginator = paginator
    }
    
    init( request: MockPaginatedRequest, paginator: StandardPaginator ) {
        self.paginator = paginator
    }
}

class MockPaginatedObject {
    var displayOrder: NSNumber!
}

final class MockPaginatedOperation: RequestOperation, PaginatedOperation {
    
    let request: MockPaginatedRequest
    private(set) var results: [AnyObject]?
    private(set) var didResetResults: Bool = false
    
    required init( request: MockPaginatedRequest = MockPaginatedRequest() ) {
        self.request = request
    }
    
    override func main() {
         self.results = self.fetchResults()
    }
    
    func fetchResults() -> [MockPaginatedObject] {
        var results = [MockPaginatedObject]()
        if self.request.paginator.pageNumber < numberOfPagesBeforeReadingEnd {
            for _ in 0..<self.request.paginator.itemsPerPage {
                results.append( MockPaginatedObject() )
            }
        }
        return results
    }
}

class PaginatedDataSourceTests: XCTestCase {
    
    var paginatedDataSource: PaginatedDataSource!
    
    override func setUp() {
        super.setUp()
        
        paginatedDataSource = PaginatedDataSource()
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func testFilters() {
        XCTFail( "TODO" )
    }

    func testUnload() {
        XCTFail( "TODO" )
    }
    
    func testLoadPagesInAscendingOrder() {
        for i in 0 ..< numberOfPagesBeforeReadingEnd {
            let expectation = expectationWithDescription("page \(i)")
            let pageType: VPageType = i == 0 ? .First : .Next
            paginatedDataSource.loadPage( pageType,
                createOperation: {
                    return MockPaginatedOperation()
                },
                completion: { (operation, error) in
                    guard let operation = operation else {
                    XCTFail( "Should receive a non-optional operation in this completion block" )
                        return
                    }
                    let pageNumber = operation.request.paginator.pageNumber
                    let itemsPerPage = operation.request.paginator.itemsPerPage
                    
                    if let results = operation.results {
                        if pageNumber < numberOfPagesBeforeReadingEnd {
                            XCTAssertEqual( results.count, itemsPerPage )
                            XCTAssertFalse( self.paginatedDataSource.didReachEndOfResults() )
                            XCTAssert( self.paginatedDataSource.canLoadPageType( .Next ) )
                        } else {
                            XCTAssertEqual( results.count, 0 )
                            XCTAssert( self.paginatedDataSource.didReachEndOfResults() )
                            XCTAssertFalse( self.paginatedDataSource.canLoadPageType( .Next ) )
                        }
                        
                    } else {
                        XCTFail( "Expecting results" )
                    }
                    expectation.fulfill()
            })
                        
            waitForExpectationsWithTimeout(1, handler: nil)
        }
    }
}
