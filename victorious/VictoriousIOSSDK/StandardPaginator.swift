//
//  StandardPaginator.swift
//  victorious
//
//  Created by Josh Hinman on 11/1/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import SwiftyJSON

final public class StandardPaginator: Paginator {
    
    /// This paginator requires knowing the result count of the previous request
    /// in order to determine if there are more pages to load.  Calling code must
    /// set this property before calling `nextPage()` for a new paginator for
    // the next page.
    public var resultCount: Int?
    public let pageNumber: Int
    public let itemsPerPage: Int
    
    public init(pageNumber: Int = 1, itemsPerPage: Int = 15) {
        self.pageNumber = pageNumber
        self.itemsPerPage = itemsPerPage
    }
    
    // MARK: - Paginator
    
    public func addPaginationArgumentsToRequest(request: NSMutableURLRequest) {
        request.URL = request.URL?.URLByAppendingPathComponent(String(pageNumber)).URLByAppendingPathComponent(String(itemsPerPage))
    }
    
    public func previousPage() -> StandardPaginator? {
        if pageNumber > 1 {
            return StandardPaginator(pageNumber: pageNumber - 1, itemsPerPage: itemsPerPage)
        }
        return nil
    }
    
    public func nextPage() -> StandardPaginator? {
        guard let resultCount = resultCount else {
            print( "The `resultCount` property has not been set on `StandardPaginator`.  This is required in order to determine if there is a next page available.  Make sure that a Pageable request sets this property after receving results." )
            return nil
        }
        if resultCount >= itemsPerPage {
            return StandardPaginator(pageNumber: pageNumber + 1, itemsPerPage: itemsPerPage)
        }
        return nil
    }
}