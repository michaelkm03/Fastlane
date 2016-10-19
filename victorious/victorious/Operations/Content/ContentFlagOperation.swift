//
//  ContentFlagOperation.swift
//  victorious
//
//  Created by Vincent Ho on 5/24/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit
import VictoriousIOSSDK

final class ContentFlagOperation: SyncOperation<Void> {
    
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
    
    override func execute() -> OperationResult<Void> {
        Content.hideContent(withID: contentID)
        RequestOperation(request: request).queue()
        return .success()
    }
}
