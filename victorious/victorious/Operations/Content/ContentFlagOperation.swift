//
//  ContentFlagOperation.swift
//  victorious
//
//  Created by Vincent Ho on 5/24/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

final class ContentFlagOperation: RequestOperation<ContentFlagRequest> {
    private let contentID: Content.ID
    
    init(contentID: Content.ID, apiPath: APIPath) {
        self.contentID = contentID
        super.init(request: ContentFlagRequest(contentID: contentID, apiPath: apiPath))
    }
    
    override func execute(finish: (result: OperationResult<ContentFlagRequest.ResultType>) -> Void) {
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
