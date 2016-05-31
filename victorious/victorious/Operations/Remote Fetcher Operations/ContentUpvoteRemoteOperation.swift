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
    
    init( contentID: String, contentUpvoteURL: String ) {
        self.request = ContentUpvoteRequest(contentID: contentID, contentUpvoteURL: contentUpvoteURL)
    }
    
    override func main() {
        requestExecutor.executeRequest( request, onComplete: nil, onError: nil )
    }
}
