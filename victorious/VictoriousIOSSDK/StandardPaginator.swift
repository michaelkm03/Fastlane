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
    
    public init(pageNumber: Int = 1, itemsPerPage: Int = 15) {
        self.pageNumber = pageNumber
        self.itemsPerPage = itemsPerPage
    }
    
    /// This Paginator requires knowing the result count of the previous request
    /// in order to determine if there are more pages to load, therefore tracking that
    /// value in this operation is required when paginated.
    public var resultCount: Int = 0
    
    public let pageNumber: Int
    
    public let itemsPerPage: Int
    
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
        if resultCount >= itemsPerPage {
            return StandardPaginator(pageNumber: pageNumber + 1, itemsPerPage: itemsPerPage)
        }
        return nil
    }
}