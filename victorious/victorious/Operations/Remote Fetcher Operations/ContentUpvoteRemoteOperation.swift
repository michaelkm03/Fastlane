//
//  ContentUpvoteRemoteOperation.swift
//  victorious
//
//  Created by Vincent Ho on 5/31/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

class ContentUpvoteRemoteOperation: RemoteFetcherOperation, RequestOperation {
    let request: ContentUpvoteRequest!
    
    init?(contentID: String, contentUpvoteURL: String) {
        guard let request = ContentUpvoteRequest(contentID: contentID, contentUpvoteURL: contentUpvoteURL) else {
            return nil
        }
        self.request = request
    }
    
    override func main() {
        requestExecutor.executeRequest( request, onComplete: nil, onError: nil)
    }
}
