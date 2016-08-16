//
//  ContentDeleteRemoteOperation.swift
//  victorious
//
//  Created by Vincent Ho on 6/10/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

class ContentDeleteRemoteOperation: RemoteFetcherOperation, RequestOperation {
    let request: ContentDeleteRequest!
    
    init?(contentID: Content.ID, apiPath: APIPath) {
        guard let request = ContentDeleteRequest(contentID: contentID, apiPath: apiPath) else {
            return nil
        }
        self.request = request
    }
    
    override func main() {
        requestExecutor.executeRequest(request, onComplete: nil, onError: nil)
    }
}
