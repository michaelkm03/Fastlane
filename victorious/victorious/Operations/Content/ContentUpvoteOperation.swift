//
//  ContentUpvoteOperation.swift
//  victorious
//
//  Created by Vincent Ho on 5/23/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

class ContentUpvoteOperation: FetcherOperation {
    private let contentID: Content.ID
    private let apiPath: APIPath
    
    init(contentID: Content.ID, apiPath: APIPath) {
        self.contentID = contentID
        self.apiPath = apiPath
    }
    
    override func main() {
        // Make data change optimistically before executing the request
        Content.likeContent(withID: contentID)
        
        ContentUpvoteRemoteOperation(contentID: contentID, apiPath: apiPath)?.after(self).queue()
    }
}
