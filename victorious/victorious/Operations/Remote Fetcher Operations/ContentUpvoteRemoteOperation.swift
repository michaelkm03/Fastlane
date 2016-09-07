//
//  ContentUpvoteRemoteOperation.swift
//  victorious
//
//  Created by Vincent Ho on 5/31/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

class ContentUpvoteRemoteOperation: RemoteFetcherOperation {
    let request: ContentUpvoteRequest!
    
    init?(contentID: Content.ID, apiPath: APIPath) {
        guard let request = ContentUpvoteRequest(contentID: contentID, apiPath: apiPath) else {
            return nil
        }
        self.request = request
    }
    
    override func main() {
        requestExecutor.executeRequest(request, onComplete: nil, onError: nil)
    }
}
