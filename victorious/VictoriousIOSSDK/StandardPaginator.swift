//
//  StandardPaginator.swift
//  victorious
//
//  Created by Josh Hinman on 11/1/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import SwiftyJSON

public struct StandardPaginator: Paginator {
    
    public init(pageNumber: Int = 1, itemsPerPage: Int = 15) {
        self.pageNumber = pageNumber
        self.itemsPerPage = itemsPerPage
    }
    
    // MARK: - Paginator
    
    public let pageNumber: Int
    
    public let itemsPerPage: Int
    
    public func addPaginationArgumentsToRequest(request: NSMutableURLRequest) {
        request.URL = request.URL?.URLByAppendingPathComponent(String(pageNumber)).URLByAppendingPathComponent(String(itemsPerPage))
    }
    
    public func previousPage() -> Paginator? {
        if pageNumber > 1 {
            return StandardPaginator(pageNumber: pageNumber - 1, itemsPerPage: itemsPerPage)
        }
        return nil
    }
    
    public func nextPage( resultCount: Int ) -> Paginator? {
        if resultCount >= itemsPerPage {
            return StandardPaginator(pageNumber: pageNumber + 1, itemsPerPage: itemsPerPage)
        }
        return nil
    }
}