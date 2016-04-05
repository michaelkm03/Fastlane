//
//  MockPagination.swift
//  victorious
//
//  Created by Patrick Lynch on 1/22/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation
@testable import victorious
@testable import VictoriousIOSSDK

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

final class MockPaginatedRemoteOperation: FetcherOperation, RequestOperation {
    
    let request: MockPaginatedRequest!
    
    required init( request: MockPaginatedRequest = MockPaginatedRequest() ) {
        self.request = request
    }
    
    override func main() {
        
    }
    
    func fetchResults() -> [AnyObject] {
        var displayOrder = self.request.paginator.displayOrderCounterStart
        var results = [MockPaginatedObject]()
        if self.request.paginator.pageNumber < numberOfPagesBeforeReachingEnd {
            for _ in 0..<self.request.paginator.itemsPerPage {
                let object = MockPaginatedObject()
                object.displayOrder = displayOrder
                displayOrder += 1
                results.append( object )
            }
        }
        return results
    }
}
