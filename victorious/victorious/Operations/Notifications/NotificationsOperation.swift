//
//  NotificationsOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 1/11/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

final class NotificationsOperation: FetcherOperation, PaginatedOperation {
    
    let paginator: StandardPaginator
    
    private var remoteOperation: NotificationsRemoteOperation?
    
    required init(paginator: StandardPaginator = StandardPaginator()) {
        self.paginator = paginator
        
        super.init()
        
        if !localFetch {
            let request = NotificationsRequest(paginator: paginator)
            remoteOperation = NotificationsRemoteOperation(request: request)
            remoteOperation?.before(self).queue()
        }
    }
    
    required convenience init(operation: NotificationsOperation, paginator: StandardPaginator) {
        self.init(paginator: paginator)
    }
    
    override func main() {
        error = remoteOperation?.error
        
        persistentStore.mainContext.v_performBlockAndWait() { context in
            let fetchRequest = NSFetchRequest(entityName: VNotification.v_entityName())
            fetchRequest.sortDescriptors = [ NSSortDescriptor(key: "displayOrder", ascending: true) ]
            self.results = context.v_executeFetchRequest( fetchRequest ) as [VNotification]
        }
    }
}
