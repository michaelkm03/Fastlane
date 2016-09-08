//
//  ContentDeleteOperation.swift
//  victorious
//
//  Created by Vincent Ho on 6/10/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

final class ContentDeleteOperation: RequestOperation<ContentDeleteRequest> {
    private let contentID: Content.ID
    
    init(contentID: Content.ID, apiPath: APIPath) {
        self.contentID = contentID
        super.init(request: ContentDeleteRequest(contentID: contentID, apiPath: apiPath))
    }
    
    override func execute(finish: (result: OperationResult<ContentDeleteRequest.ResultType>) -> Void) {
        let contentID = self.contentID
        
        super.execute { result in
            switch result {
                case .success(_):
                    Content.hideContent(withID: contentID)
                case .failure(_), .cancelled:
                    break
            }
            
            finish(result: result)
        }
    }
}
