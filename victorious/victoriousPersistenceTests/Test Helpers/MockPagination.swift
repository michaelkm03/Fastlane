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

struct MockPaginatedRequest: PaginatorPageable, ResultBasedPageable {
    
    let paginator: StandardPaginator
    var urlRequest = URLRequest(url: URL(string: "foo")!)
    
    init( paginator: StandardPaginator = StandardPaginator(pageNumber: 1, itemsPerPage: 20) ) {
        self.paginator = paginator
    }
    
    init( request: MockPaginatedRequest, paginator: StandardPaginator ) {
        self.paginator = paginator
    }
    
    func parseResponse(_ response: URLResponse, toRequest request: URLRequest, responseData: Data, responseJSON: JSON) throws -> Void { }
}

class MockPaginatedObject {
    var displayOrder: NSNumber!
}
