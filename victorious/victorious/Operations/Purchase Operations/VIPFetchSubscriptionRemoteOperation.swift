//
//  VIPFetchSubscriptionRemoteOperation.swift
//  victorious
//
//  Created by Sharif Ahmed on 7/19/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

let VIPFetchSubscriptionRemoteOperationErrorDomain = "VIPFetchSubscriptionRemoteOperationError"

class VIPFetchSubscriptionRemoteOperation: RemoteFetcherOperation {
    private static let initErrorDescription = NSLocalizedString("ProductsRequestError", comment: "")

    static let initError = NSError(domain: VIPFetchSubscriptionRemoteOperationErrorDomain, code: 0, userInfo: [ NSLocalizedDescriptionKey : initErrorDescription ] )
    
    let request: VIPFetchSubscriptionRequest!
    
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
