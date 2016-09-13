//
//  NotificationsOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 1/11/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

final class NotificationsOperation: AsyncOperation<[AnyObject]>, PaginatedOperation {
    
    // MARK: - Initializing
    
    required init(paginator: StandardPaginator = StandardPaginator()) {
        self.paginator = paginator
        request = NotificationsRequest(paginator: paginator)
        super.init()
    }
    
    required convenience init(operation: NotificationsOperation, paginator: StandardPaginator) {
        self.init(paginator: paginator)
    }
    
    // MARK: - Executing
    
    let paginator: StandardPaginator
    let request: NotificationsRequest
    var results: [AnyObject]?
    
    override var executionQueue: Queue {
        return .background
    }
    
    override func execute(finish: (result: OperationResult<[AnyObject]>) -> Void) {
        RequestOperation(request: request).queue { [weak self] result in
            switch result {
                case .success(let notifications):
                    self?.results = notifications
                    finish(result: .success(notifications))
                
                case .failure(let error):
                    self?.results = []
                    finish(result: .failure(error))
                
                case .cancelled:
                    self?.results = []
                    finish(result: .cancelled)
            }
        }
    }
}
