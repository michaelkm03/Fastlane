//
//  ContentFlagRemoteOperation.swift
//  victorious
//
//  Created by Vincent Ho on 5/24/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

class ContentFlagRemoteOperation: RemoteFetcherOperation, RequestOperation {
    let request: ContentFlagRequest!
    
    init?(contentID: String, contentFlagURL: String) {
        guard let request = ContentFlagRequest(contentID: contentID, contentFlagURL: contentFlagURL) else {
            return nil
        }
        self.request = request
    }
    
    override func main() {
        requestExecutor.executeRequest(request, onComplete: nil, onError: nil)
    }
}
