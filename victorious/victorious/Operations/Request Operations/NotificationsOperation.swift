//
//  NotificationsOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 1/11/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

final class NotificationsOperation: RequestOperation, PaginatedOperation {
    
    var request: NotificationsRequest
    
    required init( request: NotificationsRequest = NotificationsRequest() ) {
        self.request = request
    }
    
    override func main() {
        paginatedRequestExecutor.executeRequest( request, onComplete: onComplete, onError: onError )
    }
    
    func onError( error: NSError, completion:(()->()) ) {
        if error.code == RequestOperation.errorCodeNoNetworkConnection {
            self.results = fetchResults()
            
        } else {
            self.results = []
        }
        completion()
    }
    
    func onComplete( results: NotificationsRequest.ResultType, completion:()->() ) {
        guard !results.isEmpty else {
            self.results = []
            completion()
            return
        }
        
        // Make changes on background queue
        persistentStore.backgroundContext.v_performBlock() { context in
            var displayOrder = self.paginatedRequestExecutor.startingDisplayOrder
            for result in results {
                let uniqueElements = [ "remoteId" : result.notificationID ]
                let notification: VNotification = context.v_findOrCreateObject(uniqueElements)
                notification.populate(fromSourceModel: result)
                notification.displayOrder = displayOrder++
            }
            context.v_save()
            completion()
        }
    }
    
    // MARK: - PaginatedRequestExecutorDelegate
    
    override func clearResults() {
        persistentStore.backgroundContext.v_performBlockAndWait() { context in
            let existing: [VNotification] = context.v_findAllObjects()
            for object in existing {
                context.deleteObject( object )
            }
            context.v_save()
        }
    }
    
    override func fetchResults() -> [AnyObject] {
        return persistentStore.mainContext.v_performBlockAndWait() { context in
            return context.v_findAllObjects() as [VNotification
            ]
        }
    }
}
