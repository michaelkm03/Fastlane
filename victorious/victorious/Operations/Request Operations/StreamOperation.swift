//
//  StreamFetcherOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 12/4/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

final class StreamOperation: FetcherOperation, PaginatedOperation {
    
    let paginator: StreamPaginator
    private var preloadedStreamObjectID: NSManagedObjectID?
    
    required init(paginator: StreamPaginator) {
        self.paginator = paginator
        super.init()
        
        if preloadedStreamObjectID == nil && !localFetch {
            let request = StreamRequest(
                apiPath: paginator.apiPath,
                sequenceID: paginator.sequenceID,
                paginator: paginator
            )
            StreamRemoteOperation(request: request).before(self).queue()
        }
    }
    
    required convenience init(operation: StreamOperation, paginator: StreamPaginator) {
        self.init(paginator: paginator)
    }
    
    convenience init( apiPath: String, sequenceID: String? = nil, existingStreamID: NSManagedObjectID? = nil) {
        self.init( paginator: StreamPaginator(apiPath: apiPath, sequenceID: sequenceID)! )
        preloadedStreamObjectID = existingStreamID
    }
    
    override func main() {
        if let preloadedStreamObjectID = self.preloadedStreamObjectID {
            persistentStore.mainContext.v_performBlockAndWait() { context in
                guard let stream = context.objectWithID(preloadedStreamObjectID) as? VStream else {
                    return
                }
                let persistentStreamItemPointers = stream.streamItemPointers.array
                let persistentStreamItemIDs = persistentStreamItemPointers.flatMap { ($0 as? VStreamItemPointer)?.streamItem.objectID }
                self.results = persistentStreamItemIDs.flatMap {
                    context.objectWithID($0) as? VStreamItem
                }
            }
            
        } else {
            persistentStore.mainContext.v_performBlockAndWait() { context in
                let fetchRequest = NSFetchRequest(entityName: VStreamItemPointer.v_entityName())
                fetchRequest.sortDescriptors = [ NSSortDescriptor(key: "displayOrder", ascending: true) ]
                
                let streamItemPredicate = NSPredicate(format: "streamParent.apiPath == %@", self.paginator.apiPath)
                let paginationPredicate = self.paginator.paginatorPredicate
                fetchRequest.predicate = paginationPredicate + streamItemPredicate
                
                let fetchResults = context.v_executeFetchRequest( fetchRequest ) as [VStreamItemPointer]
                self.results = fetchResults.map { $0.streamItem }
            }
        }
    }
}
