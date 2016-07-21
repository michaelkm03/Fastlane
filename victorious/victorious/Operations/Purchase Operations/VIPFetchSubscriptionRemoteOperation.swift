//
//  VIPFetchSubscriptionRemoteOperation.swift
//  victorious
//
//  Created by Sharif Ahmed on 7/19/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

class VIPFetchSubscriptionRemoteOperation: RemoteFetcherOperation, RequestOperation {
    
    let request: VIPFetchSubscriptionRequest!
    
    required init(request: VIPFetchSubscriptionRequest) {
        self.request = request
    }
    
    init?(urlString: String) {
        guard let request = VIPFetchSubscriptionRequest(urlString: urlString) else {
            return nil
        }
        self.request = request
    }
    
    override func main() {
        requestExecutor.executeRequest(request, onComplete: onComplete, onError: nil)
    }
    
    func onComplete(result: VIPFetchSubscriptionRequest.ResultType ) {
        self.results = result
    }
}
