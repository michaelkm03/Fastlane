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
    
    init?(apiPath: APIPath, contentID: Content.ID) {
        guard let request = ContentFlagRequest(apiPath: apiPath, contentID: contentID) else {
            return nil
        }
        
        self.request = request
        self.contentID = contentID
        super.init()
    }
    
    // MARK: - Executing
    
    private let request: ContentFlagRequest
    private let contentID: Content.ID
    
    override var executionQueue: Queue {
        return .main
    }
    
    override func execute(finish: (result: OperationResult<Void>) -> Void) {
        let contentID = self.contentID
        
        RequestOperation(request: request).queue { result in
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
