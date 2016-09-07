//
//  ContentFeedOperation.swift
//  victorious
//
//  Created by Jarod Long on 9/7/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

final class ContentFeedOperation: RequestOperation<ContentFeedRequest> {
    init(apiPath: APIPath) {
        super.init(request: ContentFeedRequest(apiPath: apiPath))
    }
    
    override func execute(finish: (result: OperationResult<ContentFeedRequest.ResultType>) -> Void) {
        super.execute { result in
            switch result {
                case .success(let items, let refreshStage):
                    let unhiddenContents = items.filter { content in
                        guard let id = content.id else {
                            return true
                        }
                        
                        return !Content.contentIsHidden(withID: id)
                    }
                    
                    finish(result: .success((
                        contents: unhiddenContents,
                        refreshStage: refreshStage
                    )))
                
                case .failure(_), .cancelled:
                    finish(result: result)
            }
        }
    }
}
