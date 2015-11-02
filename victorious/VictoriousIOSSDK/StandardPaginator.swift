//
//  StandardPaginator.swift
//  victorious
//
//  Created by Josh Hinman on 11/1/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import SwiftyJSON

public struct StandardPaginator: PaginatorType {
    
    private let currentContinuation: StandardPaginatorContinuation
    
    public func paginatedRequestWithRequest(request: NSURLRequest) -> NSURLRequest {
        let mutableRequest = request.mutableCopy() as! NSMutableURLRequest
        mutableRequest.URL = mutableRequest.URL?.URLByAppendingPathComponent(String(currentContinuation.pageNumber)).URLByAppendingPathComponent(String(currentContinuation.itemsPerPage))
        return mutableRequest
    }
    
    public func parsePageInformationFromResponse(response: NSURLResponse, toRequest request: NSURLRequest, responseData: NSData, responseJSON: JSON) -> (nextPage: StandardPaginatorContinuation?, previousPage: StandardPaginatorContinuation?) {
        
        let nextPage: StandardPaginatorContinuation?
        if responseJSON["total_pages"].int > currentContinuation.pageNumber {
            nextPage = StandardPaginatorContinuation(pageNumber: currentContinuation.pageNumber + 1, itemsPerPage: currentContinuation.itemsPerPage)
        } else {
            nextPage = nil
        }
        
        let previousPage: StandardPaginatorContinuation?
        if currentContinuation.pageNumber > 1 {
            previousPage = StandardPaginatorContinuation(pageNumber: currentContinuation.pageNumber - 1, itemsPerPage: currentContinuation.itemsPerPage)
        } else {
            previousPage = nil
        }
        
        return (nextPage, previousPage)
    }
    
    public init(pageNumber: Int = 1, itemsPerPage: Int = 15) {
        currentContinuation = StandardPaginatorContinuation(pageNumber: pageNumber, itemsPerPage: itemsPerPage)
    }
    
    public init(continuation: StandardPaginatorContinuation) {
        currentContinuation = continuation
    }
}

public struct StandardPaginatorContinuation {
    private let pageNumber: Int
    private let itemsPerPage: Int
}
