//
//  GIFSearchOperation.swift
//  victorious
//
//  Created by Tian Lan on 11/30/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

final class GIFSearchOperation: RequestOperation<GIFSearchRequest>, PageableOperation {
    private(set) var searchResults: [GIFSearchResult] = []
    
    private(set) var nextPageOperation: GIFSearchOperation?
    private(set) var previousPageOperation: GIFSearchOperation?
    
    init(searchText: String) {
        super.init(request: GIFSearchRequest(searchTerm: searchText))
    }
    
    override init(request: GIFSearchRequest) {
        super.init(request: request)
    }
    
    override func onComplete(result: GIFSearchRequest.ResultType, completion: () -> ()) {
        searchResults = result.results
        if let nextPageRequest = result.nextPage {
            nextPageOperation = GIFSearchOperation(request: nextPageRequest)
        }
        if let previousPageRequest = result.previousPage {
            previousPageOperation = GIFSearchOperation(request: previousPageRequest)
        }
        completion()
    }
}
