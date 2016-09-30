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
        request = InAppNotificationsRequest(paginator: paginator)
        super.init()
    }
    
    required convenience init(operation: NotificationsOperation, paginator: StandardPaginator) {
        self.init(paginator: paginator)
    }
    
    // MARK: - Executing
    
    let paginator: StandardPaginator
    let request: InAppNotificationsRequest
    var results: [AnyObject]?
    
    override var executionQueue: Queue {
        return .background
    }
    
    override func execute(_ finish: @escaping (_ result: OperationResult<[AnyObject]>) -> Void) {
        RequestOperation(request: request).queue { [weak self] result in
            switch result {
                case .success(let notifications):
                    self?.results = notifications
                    finish(.success(notifications))
                
                case .failure(let error):
                    self?.results = []
                    finish(.failure(error))
                
                case .cancelled:
                    self?.results = []
                    finish(.cancelled)
            }
        }
    }
}
