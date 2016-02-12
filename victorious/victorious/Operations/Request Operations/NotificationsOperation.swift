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
            var displayOrder = self.request.paginator.displayOrderCounterStart
            for result in results {
                
                /// Determining uniqueness based on time of creation and subject of the notification
                let uniqueElements : [String : AnyObject] = [
                    "createdAt" : result.createdAt,
                    "subject" : result.subject
                ]
                
                let notification: VNotification = context.v_findOrCreateObject(uniqueElements)
                notification.populate(fromSourceModel: result)
                notification.displayOrder = displayOrder++
            }
            context.v_save()
            dispatch_async( dispatch_get_main_queue() ) {
                self.results = self.fetchResults()
                completion()
            }
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
