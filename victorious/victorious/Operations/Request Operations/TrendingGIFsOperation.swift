//
//  TrendingGIFsOperation.swift
//  victorious
//
//  Created by Tian Lan on 12/1/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

final class TrendingGIFsOperation: RequestOperation, PaginatedOperation {
    
    let request: TrendingGIFsRequest
    
    private(set) var trendingGIFsResults: [GIFSearchResult] = []
    private(set) var resultCount: Int?
    
    required init( request: TrendingGIFsRequest = TrendingGIFsRequest() ) {
        self.request = request
    }
    
    override func main() {
        executeRequest( request, onComplete: self.onComplete )
    }
    
    func onComplete(results: TrendingGIFsRequest.ResultType, completion: () -> ()) {
        self.resultCount = results.count
        self.trendingGIFsResults = results
        completion()
    }
}
