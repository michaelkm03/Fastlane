//
//  TrendingGIFsOperation.swift
//  victorious
//
//  Created by Tian Lan on 12/1/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

class TrendingGIFsOperation: RequestOperation<TrendingGIFsRequest> {
    private(set) var trendingGIFsResults: [GIFSearchResult] = []
    private(set) var nextPageOperation: TrendingGIFsOperation?
    private(set) var previousPageOperation: TrendingGIFsOperation?
    
    init() {
        super.init(request: TrendingGIFsRequest())
    }
    
    override init(request: TrendingGIFsRequest) {
        super.init(request: request)
    }
    
    override func onComplete(result: TrendingGIFsRequest.ResultType, completion: () -> ()) {
        trendingGIFsResults = result.results.flatMap() {
            GIFSearchResult(networkingSearchResultModel: $0)
        }
        if let nextPageRequest = result.nextPage {
            nextPageOperation = TrendingGIFsOperation(request: nextPageRequest)
        }
        if let previousPageRequest = result.previousPage {
            previousPageOperation = TrendingGIFsOperation(request: previousPageRequest)
        }
        completion()
    }
}
