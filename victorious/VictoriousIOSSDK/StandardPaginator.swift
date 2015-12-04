//
//  StandardPaginator.swift
//  victorious
//
//  Created by Josh Hinman on 11/1/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import SwiftyJSON

public protocol PaginatorType {
    
    var pageNumber: Int { get }
    
    var itemsPerPage: Int { get }
    
    /// Returns a PaginatorType object that contains data for retrieving the next page
    /// of paginated data after the receiver.
    func getPreviousPage() -> PaginatorType?
    
    /// Returns a PaginatorType object that contains data for retrieving the next page
    /// of paginated data after the receiver.
    func getNextPage( resultCount: Int ) -> PaginatorType?
    
    /// Modifies the provided request by adding pagination data to it according to
    /// the implementation-specific logic for doing so.
    func addPaginationArgumentsToRequest(request: NSMutableURLRequest)
}

public struct StandardPaginator: PaginatorType {
    
    public init(pageNumber: Int = 1, itemsPerPage: Int = 15) {
        self.pageNumber = pageNumber
        self.itemsPerPage = itemsPerPage
    }
    
    // MARK: - PaginatorType
    
    public let pageNumber: Int
    
    public let itemsPerPage: Int
    
    public func addPaginationArgumentsToRequest(request: NSMutableURLRequest) {
        request.URL = request.URL?.URLByAppendingPathComponent(String(pageNumber)).URLByAppendingPathComponent(String(itemsPerPage))
    }
    
    public func getPreviousPage() -> PaginatorType? {
        if pageNumber > 1 {
            return StandardPaginator(pageNumber: pageNumber - 1, itemsPerPage: itemsPerPage)
        }
        return nil
    }
    
    public func getNextPage( resultCount: Int ) -> PaginatorType? {
        if resultCount >= itemsPerPage {
            return StandardPaginator(pageNumber: pageNumber + 1, itemsPerPage: itemsPerPage)
        }
        return nil
    }
    
    // FIXME: Delete these and replace uses
    
    public var previousPage: StandardPaginator? {
        if pageNumber > 1 {
            return StandardPaginator(pageNumber: pageNumber - 1, itemsPerPage: itemsPerPage)
        }
        return nil
    }
    
    public var nextPage: StandardPaginator {
        return StandardPaginator(pageNumber: pageNumber + 1, itemsPerPage: itemsPerPage)
    }
}