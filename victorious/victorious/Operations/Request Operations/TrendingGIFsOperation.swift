//
//  TrendingGIFsOperation.swift
//  victorious
//
//  Created by Tian Lan on 12/1/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

// TODO: Rename this and the request to `GIFSearchDefaultResults` or something...
final class TrendingGIFsOperation: RequestOperation, PaginatedOperation {
    
    let request: TrendingGIFsRequest
    
    private(set) var results: [AnyObject]?
    
    required init( request: TrendingGIFsRequest = TrendingGIFsRequest() ) {
        self.request = request
    }
    
    override func main() {
        executeRequest( request, onComplete: self.onComplete, onError: self.onError )
    }
    
    func onError( error: NSError, completion:()->() ) {
        self.results = []
        completion()
    }
    
    func onComplete(results: TrendingGIFsRequest.ResultType, completion: () -> ()) {
        self.results = results.map { GIFSearchResultObject($0) }
        completion()
    }
}
