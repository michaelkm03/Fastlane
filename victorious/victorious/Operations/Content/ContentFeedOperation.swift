//
//  ContentFeedOperation.swift
//  victorious
//
//  Created by Jarod Long on 9/7/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

final class ContentFeedOperation: AsyncOperation<ContentFeedResult> {
    
    // MARK: - Initializing
    
    init(apiPath: APIPath) {
        self.apiPath = apiPath
        super.init()
    }
    
    // MARK: - Executing
    
    private let apiPath: APIPath
    
    override var executionQueue: Queue {
        return .main
    }
    
    override func execute(finish: (result: OperationResult<ContentFeedResult>) -> Void) {
        RequestOperation(request: ContentFeedRequest(apiPath: apiPath)).queue { result in
            switch result {
                case .success(var feedResult):
                    feedResult.contents = feedResult.contents.filter { content in
                        guard let id = content.id else {
                            return true
                        }
                        
                        return !Content.contentIsHidden(withID: id)
                    }
                    
                    finish(result: .success(feedResult))
                
                case .failure(_), .cancelled:
                    finish(result: result)
            }
        }
    }
}
