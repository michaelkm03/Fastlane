//
//  ContentDeleteOperation.swift
//  victorious
//
//  Created by Vincent Ho on 6/10/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

final class ContentDeleteOperation: AsyncOperation<Void> {
    
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
    
    override func execute(finish: (result: OperationResult<Void>) -> Void) {
        let contentID = self.contentID
        
        RequestOperation(request: request).queue { result in
            switch result {
                case .success:
                    Content.hideContent(withID: contentID)
                case .failure(_), .cancelled:
                    break
            }
            
            finish(result: result)
        }
    }
}
