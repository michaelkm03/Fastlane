//
//  ContentFetchOperation.swift
//  victorious
//
//  Created by Vincent Ho on 5/6/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit
import VictoriousIOSSDK

final class ContentFetchOperation: AsyncOperation<Content> {
    
    // MARK: - Initializing
    
    init?(apiPath: APIPath, currentUserID: String, contentID: String) {
        guard let request = ContentFetchRequest(apiPath: apiPath, currentUserID: currentUserID, contentID: contentID) else {
            return nil
        }
        
        self.request = request
        super.init()
    }
    
    // MARK: - Executing
    
    private let request: ContentFetchRequest
    
    override var executionQueue: Queue {
        return .background
    }
    
    override func execute(_ finish: @escaping (_ result: OperationResult<Content>) -> Void) {
        RequestOperation(request: request).queue { result in
            switch result {
                case .success(let content):
                    if let id = content.id , Content.contentIsHidden(withID: id) {
                        finish(.failure(NSError(domain: "ContentFetchOperation", code: -1, userInfo: nil)))
                    }
                    else {
                        finish(result)
                    }
                
                case .failure(_), .cancelled:
                    finish(result)
            }
        }
    }
}
