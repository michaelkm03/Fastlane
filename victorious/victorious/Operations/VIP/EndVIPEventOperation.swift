//
//  EndVIPEventOperation.swift
//  victorious
//
//  Created by Vincent Ho on 9/28/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

final class EndVIPEventOperation: SyncOperation<Void> {
    
    // MARK: - Initializing
    
    init?(apiPath: APIPath) {
        guard let request = EndVIPEventRequest(apiPath: apiPath) else {
            return nil
        }
        
        self.request = request
        super.init()
    }
    
    // MARK: - Executing
    
    private let request: EndVIPEventRequest
    
    override var executionQueue: Queue {
        return .main
    }
    
    override func execute() -> OperationResult<Void> {
        RequestOperation(request: request).queue()
        return .success()
    }
}
