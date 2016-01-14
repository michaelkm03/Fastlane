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
        requestExecutor.executeRequest( request, onComplete: onComplete, onError: nil )
    }
    
    func onComplete( results: NotificationsRequest.ResultType, completion:()->() ) {
        guard !results.isEmpty else {
            completion()
            return
        }
        
        storedBackgroundContext = persistentStore.createBackgroundContext().v_performBlock() { context in
            var displayOrder = self.request.paginator.start
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
    
    // MARK: - PaginatedOperation
    
    internal(set) var results: [AnyObject]?
    
    func clearResults() {
        persistentStore.createBackgroundContext().v_performBlockAndWait() { context in
            let existing: [VNotification] = context.v_findAllObjects()
            for object in existing {
                context.deleteObject( object )
            }
            context.v_save()
        }
    }
    
    func fetchResults() -> [AnyObject] {
        return persistentStore.mainContext.v_performBlockAndWait() { context in
            let fetchRequest = NSFetchRequest(entityName: VNotification.v_entityName())
            fetchRequest.sortDescriptors = [ NSSortDescriptor(key: "displayOrder", ascending: true) ]
            return context.v_executeFetchRequest( fetchRequest ) as [VNotification]
        }
    }
}
