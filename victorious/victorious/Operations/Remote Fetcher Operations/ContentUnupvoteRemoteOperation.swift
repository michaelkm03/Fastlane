//
//  ContentUnupvoteRemoteOperation.swift
//  victorious
//
//  Created by Vincent Ho on 5/31/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

class ContentUnupvoteRemoteOperation: RemoteFetcherOperation, RequestOperation {
    let request: ContentUnupvoteRequest!
    
    init?(contentID: String, contentUnupvoteURL: String) {
        guard let request = ContentUnupvoteRequest(contentID: contentID, contentUnupvoteURL: contentUnupvoteURL) else {
            return nil
        }
        self.request = request
    }
    
    override func main() {
        requestExecutor.executeRequest(request, onComplete: nil, onError: nil)
    }
}
