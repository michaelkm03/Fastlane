//
//  ContentUpvoteOperation.swift
//  victorious
//
//  Created by Vincent Ho on 5/23/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

final class ContentUpvoteOperation: AsyncOperation<Void> {
    
    // MARK: - Initializing
    
    init(contentID: Content.ID, apiPath: APIPath) {
        self.contentID = contentID
        self.apiPath = apiPath
        super.init()
    }
    
    // MARK: - Executing
    
    private let contentID: Content.ID
    private let apiPath: APIPath
    
    override var executionQueue: Queue {
        return .main
    }
    
    override func execute(finish: (result: OperationResult<Void>) -> Void) {
        Content.likeContent(withID: contentID)
        RequestOperation(request: ContentUpvoteRequest(contentID: contentID, apiPath: apiPath)).queue(completion: finish)
    }
}
