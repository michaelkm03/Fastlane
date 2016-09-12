//
//  ContentFetchOperation.swift
//  victorious
//
//  Created by Vincent Ho on 5/6/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

final class ContentFetchOperation: AsyncOperation<Content> {
    
    // MARK: - Initializing
    
    init(macroURLString: String, currentUserID: String, contentID: String) {
        request = ContentFetchRequest(macroURLString: macroURLString, currentUserID: currentUserID, contentID: contentID)
        super.init()
    }
    
    // MARK: - Executing
    
    private let request: ContentFetchRequest
    
    override var executionQueue: Queue {
        return .main
    }
    
    override func execute(finish: (result: OperationResult<Content>) -> Void) {
        RequestOperation(request: request).queue { result in
            switch result {
                case .success(let content):
                    if let id = content.id where Content.contentIsHidden(withID: id) {
                        finish(result: .failure(NSError(domain: "ContentFetchOperation", code: -1, userInfo: nil)))
                    }
                    else {
                        finish(result: result)
                    }
                
                case .failure(_), .cancelled:
                    finish(result: result)
            }
        }
    }
}
