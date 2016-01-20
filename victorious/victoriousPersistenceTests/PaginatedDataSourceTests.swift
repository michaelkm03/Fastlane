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

private let numberOfPagesBeforeReachingEnd = 5

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
    
    required init( request: MockPaginatedRequest = MockPaginatedRequest() ) {
        self.request = request
    }
    
    override func main() {
         
    }
    
    internal(set) var results: [AnyObject]?
    
    func clearResults() {

    }
    
    func fetchResults() -> [AnyObject] {
        var displayOrder = self.request.paginator.start
        var results = [MockPaginatedObject]()
        if self.request.paginator.pageNumber < numberOfPagesBeforeReachingEnd {
            for _ in 0..<self.request.paginator.itemsPerPage {
                let object = MockPaginatedObject()
                object.displayOrder = displayOrder++
                results.append( object )
            }
        }
        return results
    }
}

class PaginatedDataSourceTests: XCTestCase, PaginatedDataSourceDelegate {
    
    var paginatedDataSource: PaginatedDataSource!
    var paginatedDataSourceUpdateCount: Int = 0
    var paginatedDataSourceDidUpdateBlock: ((oldValue: NSOrderedSet, newValue: NSOrderedSet) -> Void)? = nil
    
    func paginatedDataSource( paginatedDataSource: PaginatedDataSource, didUpdateVisibleItemsFrom oldValue: NSOrderedSet, to newValue: NSOrderedSet) {
        self.paginatedDataSourceDidUpdateBlock?( oldValue: oldValue, newValue: newValue )
    }
    
    override func setUp() {
        super.setUp()
        
        paginatedDataSourceUpdateCount = 0
        paginatedDataSource = PaginatedDataSource()
        paginatedDataSource.delegate = self
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func testUnload() {
        let expectation = expectationWithDescription("testUnload")
        let pageType: VPageType = .First
        paginatedDataSource.loadPage( pageType,
            createOperation: {
                return MockPaginatedOperation()
            },
            completion: { (operation, error) in
                expectation.fulfill()
                
                guard let operation = operation else {
                    XCTFail( "Should receive a non-optional operation in this completion block" )
                    return
                }
                let itemsPerPage = operation.request.paginator.itemsPerPage
                
                if let results = operation.results {
                    XCTAssertFalse( results.isEmpty )
                    XCTAssertEqual( results.count, itemsPerPage )
                    self.paginatedDataSourceDidUpdateBlock = { (oldValue, newValue) in
                        self.paginatedDataSourceUpdateCount++
                        XCTAssertEqual( self.paginatedDataSource.visibleItems.count, 0 )
                    }
                    self.paginatedDataSource.unload()
                    XCTAssertEqual( self.paginatedDataSourceUpdateCount, 1 )
                    
                } else {
                    XCTFail( "Expecting results" )
                }
            }
        )
        waitForExpectationsWithTimeout(1, handler: nil)
    }
    
    func testLoadPagesInAscendingOrder() {
        for i in 0 ..< numberOfPagesBeforeReachingEnd {
            let expectation = expectationWithDescription("page \(i)")
            let pageType: VPageType = i == 0 ? .First : .Next
            paginatedDataSource.loadPage( pageType,
                createOperation: {
                    return MockPaginatedOperation()
                },
                completion: { (operation, error) in
                    expectation.fulfill()
                    
                    guard let operation = operation else {
                    XCTFail( "Should receive a non-optional operation in this completion block" )
                        return
                    }
                    let pageNumber = operation.request.paginator.pageNumber
                    let itemsPerPage = operation.request.paginator.itemsPerPage
                    
                    if let results = operation.results {
                        if pageNumber < numberOfPagesBeforeReachingEnd {
                            XCTAssertEqual( results.count, itemsPerPage )
                            XCTAssertNotNil( self.paginatedDataSource.currentOperation )
                        } else {
                            XCTAssertEqual( results.count, 0 )
                        }
                        
                    } else {
                        XCTFail( "Expecting results" )
                    }
                }
            )
                        
            waitForExpectationsWithTimeout(1, handler: nil)
        }
    }
}
