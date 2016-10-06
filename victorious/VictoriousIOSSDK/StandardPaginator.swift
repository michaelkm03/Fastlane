//
//  StandardPaginator.swift
//  victorious
//
//  Created by Josh Hinman on 11/1/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation

public struct StandardPaginator: NumericPaginator {
    
    public let pageNumber: Int
    public let itemsPerPage: Int
    
    public init(pageNumber: Int = 1, itemsPerPage: Int = 15) {
        self.pageNumber = pageNumber
        self.itemsPerPage = itemsPerPage
    }
    
    // MARK: - Paginator
    
    public func addPaginationArguments(to request: inout URLRequest) {
        request.url?.appendPathComponent(String(pageNumber))
        request.url?.appendPathComponent(String(itemsPerPage))
    }
    
    public func previousPage() -> StandardPaginator? {
        if pageNumber > 1 {
            return StandardPaginator(pageNumber: pageNumber - 1, itemsPerPage: itemsPerPage)
        }
        return nil
    }
    
    public func nextPage( resultCount: Int ) -> StandardPaginator? {
        if resultCount > 0 {
            return StandardPaginator(pageNumber: pageNumber + 1, itemsPerPage: itemsPerPage)
        }
        return nil
    }
}
