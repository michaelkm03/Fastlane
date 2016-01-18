//
//  TrendingHashtagOperation.swift
//  victorious
//
//  Created by Tian Lan on 1/18/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

class TrendingHashtagOperation: RequestOperation {
    
    let request = TrendingHashtagRequest()
    private(set) var results: [HashtagSearchResultObject]?
    
    override func main() {
        requestExecutor.executeRequest(request, onComplete: onComplete, onError: nil)
    }

    func onComplete( networkResult: TrendingHashtagRequest.ResultType, completion: () -> () ) {
        self.results = networkResult.map{ HashtagSearchResultObject(hashtag: $0) }
        
        // Queue parsing of network results into persistent store to execute after this operation completes
        // This allows calling code to receive the `resutls` above without having to wait
        // until all the hashtags are parsed and saved to the persistent store
        SaveHashtagsOperation(hashtags: networkResult).queueAfter(self)
        
        completion()
    }
}
