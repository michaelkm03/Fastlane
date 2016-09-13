//
//  ContentUnupvoteOperation.swift
//  victorious
//
//  Created by Vincent Ho on 5/23/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

final class ContentUnupvoteOperation: SyncOperation<Void> {
    
    // MARK: - Initializing
    
    init?(apiPath: APIPath, contentID: Content.ID) {
        guard let request = ContentUnupvoteRequest(apiPath: apiPath, contentID: contentID) else {
            return nil
        }
        
        self.contentID = contentID
        self.request = request
        super.init()
    }
    
    // MARK: - Executing
    
    private let contentID: Content.ID
    private let request: ContentUnupvoteRequest
    
    override var executionQueue: Queue {
        return .main
    }
    
    override func execute() -> OperationResult<Void> {
        Content.unlikeContent(withID: contentID)
        RequestOperation(request: request).queue()
        return .success()
    }
}
