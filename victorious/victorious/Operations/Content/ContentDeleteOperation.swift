//
//  ContentDeleteOperation.swift
//  victorious
//
//  Created by Vincent Ho on 6/10/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

final class ContentDeleteOperation: SyncOperation<Void> {
    
    // MARK: - Initializing
    
    init?(apiPath: APIPath, contentID: Content.ID) {
        guard let request = ContentDeleteRequest(apiPath: apiPath, contentID: contentID) else {
            return nil
        }
        
        self.request = request
        self.contentID = contentID
        super.init()
    }
    
    // MARK: - Executing
    
    private let request: ContentDeleteRequest
    private let contentID: Content.ID
    
    override var executionQueue: Queue {
        return .main
    }
    
    override func execute() -> OperationResult<Void> {
        Content.hideContent(withID: contentID)
        RequestOperation(request: request).queue()
        return .success()
    }
}
