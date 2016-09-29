//
//  ContentFeedOperation.swift
//  victorious
//
//  Created by Jarod Long on 9/7/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

final class ContentFeedOperation: AsyncOperation<ContentFeedResult> {
    
    // MARK: - Initializing
    
    init?(apiPath: APIPath, payloadType: ContentFeedPayloadType) {
        guard let request = ContentFeedRequest(apiPath: apiPath, payloadType: payloadType) else {
            return nil
        }
        
        self.request = request
        super.init()
    }
    
    // MARK: - Executing
    
    fileprivate let request: ContentFeedRequest
    
    override var executionQueue: Queue {
        return .main
    }
    
    override func execute(_ finish: @escaping (_ result: OperationResult<ContentFeedResult>) -> Void) {
        RequestOperation(request: request).queue { result in
            switch result {
                case .success(var feedResult):
                    feedResult.contents = feedResult.contents.filter { content in
                        guard let id = content.id else {
                            return true
                        }
                        
                        return !Content.contentIsHidden(withID: id)
                    }
                    
                    finish(.success(feedResult))
                
                case .failure(_), .cancelled:
                    finish(result)
            }
        }
    }
}
