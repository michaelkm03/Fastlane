//
//  NotificationsRemoteOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 3/3/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

final class NotificationsRemoteOperation: RemoteFetcherOperation, PaginatedRequestOperation {
    
    var request: NotificationsRequest
    
    required init(request: NotificationsRequest = NotificationsRequest()) {
        self.request = request
    }
    
    override func main() {
        requestExecutor.executeRequest(request, onComplete: onComplete, onError: onError)
    }
    
    func onComplete(results: NotificationsRequest.ResultType) {
        guard !results.isEmpty else {
            return
        }
        
        persistentStore.createBackgroundContext().v_performBlockAndWait() { context in
            var displayOrder = self.request.paginator.displayOrderCounterStart
            for result in results {
                
                /// Determining uniqueness based on time of creation and subject of the notification
                let uniqueElements: [String : AnyObject] = [
                    "createdAt": result.createdAt,
                    "subject": result.subject
                ]
                
                let notification: VNotification = context.v_findOrCreateObject(uniqueElements)
                notification.populate(fromSourceModel: result)
                notification.displayOrder = displayOrder
                displayOrder += 1
            }
            context.v_save()
        }
    }
    
    func onError(error: NSError?) {
        self.error = error
    }
}
