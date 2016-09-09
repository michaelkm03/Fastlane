//
//  ContentFlagOperation.swift
//  victorious
//
//  Created by Vincent Ho on 5/24/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

final class ContentFlagOperation: AsyncOperation<Void> {
    
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
        let contentID = self.contentID
        
        RequestOperation(request: ContentFlagRequest(contentID: contentID, apiPath: apiPath)).queue { result in
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
