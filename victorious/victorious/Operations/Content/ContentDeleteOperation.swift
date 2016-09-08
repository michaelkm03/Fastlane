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
        
        RequestOperation(request: ContentDeleteRequest(contentID: contentID, apiPath: apiPath)).queue { result in
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
