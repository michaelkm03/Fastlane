//
//  VIPFetchSubscriptionRemoteOperation.swift
//  victorious
//
//  Created by Sharif Ahmed on 7/19/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

let VIPFetchSubscriptionRemoteOperationErrorDomain = "VIPFetchSubscriptionRemoteOperationError"

class VIPFetchSubscriptionRemoteOperation: RemoteFetcherOperation, RequestOperation {
    private static let initErrorDescription = NSLocalizedString("ProductsRequestError", comment: "")

    private static let initError = NSError(domain: VIPFetchSubscriptionRemoteOperationErrorDomain, code: 0, userInfo: [ NSLocalizedDescriptionKey : initErrorDescription ] )
    
    let request: VIPFetchSubscriptionRequest!
    
    required init(request: VIPFetchSubscriptionRequest) {
        self.request = request
    }
    
    init(urlString: String) throws {
        guard let request = VIPFetchSubscriptionRequest(urlString: urlString) else {
            throw VIPFetchSubscriptionRemoteOperation.initError
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
