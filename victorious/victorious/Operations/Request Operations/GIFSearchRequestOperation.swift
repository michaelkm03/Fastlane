//
//  GIFSearchRequestOperation.swift
//  victorious
//
//  Created by Tian Lan on 11/30/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

class GIFSearchRequestOperation: RequestOperation<GIFSearchRequest> {
    private(set) var searchResults: [GIFSearchResult] = []
    private(set) var nextPageOperation: GIFSearchRequestOperation?
    private(set) var previousPageOperation: GIFSearchRequestOperation?
    
    init(searchText: String) {
        super.init(request: GIFSearchRequest(searchTerm: searchText))
    }
    
    override init(request: GIFSearchRequest) {
        super.init(request: request)
    }
    
    override func onComplete(result: GIFSearchRequest.ResultType, completion: () -> ()) {
        searchResults = result.results.flatMap() {
            GIFSearchResult(networkingSearchResultModel: $0)
        }
        if let nextPageRequest = result.nextPage {
            nextPageOperation = GIFSearchRequestOperation(request: nextPageRequest)
        }
        if let previousPageRequest = result.previousPage {
            previousPageOperation = GIFSearchRequestOperation(request: previousPageRequest)
        }
        completion()
    }
}
