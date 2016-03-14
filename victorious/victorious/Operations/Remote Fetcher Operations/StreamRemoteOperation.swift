//
//  StreamRemoteOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 3/3/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

final class StreamRemoteOperation: RemoteFetcherOperation, PaginatedRequestOperation {
    
    let request: StreamRequest
    
    private var persistentStreamItemIDs: [NSManagedObjectID]?
    
    required init( request: StreamRequest ) {
        self.request = request
    }
    
    convenience init( apiPath: String, sequenceID: String? = nil) {
        self.init( request: StreamRequest(apiPath: apiPath, sequenceID: sequenceID)! )
    }
    
    override func main() {
        requestExecutor.executeRequest( request, onComplete: self.onComplete, onError:nil )
    }
    
    func onComplete( sourceStream: StreamRequest.ResultType) {
        
        // Make changes on background queue
        persistentStore.createBackgroundContext().v_performBlockAndWait() { context in
            
            // This is a hack to refresh streams.  `PaginatedDataSource` should really handle
            // this logic for all paginated operations.
            if self.request.paginator.pageNumber == 1 {
                let fetchRequest = NSFetchRequest(entityName: VStreamItemPointer.v_entityName() )
                fetchRequest.predicate = NSPredicate(format: "streamParent.apiPath == %@", self.request.apiPath)
                context.v_deleteObjects( fetchRequest )
            }
            
            // Parse stream
            let stream: VStream = context.v_findOrCreateObject( [ "apiPath" : self.request.apiPath ] )
            
            stream.populate(fromSourceModel: sourceStream)
            
            // If there are any stream items returned from the network:
            let persistentStreamItemPointers: NSOrderedSet
            if let streamItemIDs = sourceStream.items?.flatMap({ $0.streamItemID }) where !streamItemIDs.isEmpty {
                
                // Using a list of streamIDs that we've just received from the network,
                // get the corresponding persistent stream items from the stream
                persistentStreamItemPointers = stream.streamItemPointersForStreamItemIDs(streamItemIDs)
                
                // Assign display order to stream item pointers that were parsed in `populate` method above
                var displayOrder = self.request.paginator.displayOrderCounterStart
                for pointer in persistentStreamItemPointers.flatMap({ $0 as? VStreamItemPointer }) {
                    pointer.displayOrder = displayOrder++
                }
                
            } else {
                persistentStreamItemPointers = []
            }
            
            context.v_save()
            
            let persistentStreamItemIDs = persistentStreamItemPointers.flatMap { ($0 as? VStreamItemPointer)?.streamItem.objectID }
            self.persistentStore.mainContext.v_performBlockAndWait() { context in
                self.results = persistentStreamItemIDs.flatMap {
                    context.objectWithID($0) as? VStreamItem
                }
            }
        }
    }
}
