//
//  ContentDeleteOperation.swift
//  victorious
//
//  Created by Vincent Ho on 6/10/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

class ContentDeleteOperation: FetcherOperation {
    private let contentID: Content.ID
    private let apiPath: APIPath
    
    init(contentID: Content.ID, apiPath: APIPath) {
        self.contentID = contentID
        self.apiPath = apiPath
    }
    
    override func main() {
        guard
            didConfirmActionFromDependencies,
            let request = ContentDeleteRequest(contentID: contentID, apiPath: apiPath)
        else {
            cancel()
            return
        }
        
        Content.hideContent(withID: contentID)
        
        let requestOperation = RequestOperation(request: request)
        requestOperation.after(self).queue()
    }
}
