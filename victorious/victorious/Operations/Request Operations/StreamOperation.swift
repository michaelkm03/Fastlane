//
//  StreamOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 12/4/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

final class StreamOperation: FetcherOperation, PaginatedRequestOperation {
    
    let request: StreamRequest
    
    private let apiPath: String
    
    private var persistentStreamItemIDs: [NSManagedObjectID]?
    private var preloadedStreamObjectID: NSManagedObjectID?
    
    required init( request: StreamRequest ) {
        self.apiPath = request.apiPath
        self.request = request
    }
    
    convenience init( apiPath: String, sequenceID: String? = nil, existingStreamID: NSManagedObjectID? = nil) {
        self.init( request: StreamRequest(apiPath: apiPath, sequenceID: sequenceID)! )
        preloadedStreamObjectID = existingStreamID
    }
    
    override func main() {
        if let preloadedStreamObjectID = self.preloadedStreamObjectID {
            dispatch_sync( dispatch_get_main_queue() ) {
                self.results = self.fetchLocalResults( preloadedStreamObjectID )
            }
            
        } else {
            requestExecutor.executeRequest( request, onComplete: self.onComplete, onError:nil )
        }
    }
    
    func onComplete( sourceStream: StreamRequest.ResultType, completion:()->() ) {
        
        // Make changes on background queue
        storedBackgroundContext = persistentStore.createBackgroundContext().v_performBlock() { context in
            
            // This is a hack to refresh streams.  `PaginatedDataSource` should really handle
            // this logic for all paginated operations.
            if self.request.paginator.pageNumber == 1 {
                let fetchRequest = NSFetchRequest(entityName: VStreamItemPointer.v_entityName() )
                fetchRequest.predicate = NSPredicate(format: "streamParent.apiPath == %@", self.apiPath)
                context.v_deleteObjects( fetchRequest )
            }
            
            // Parse stream
            let stream: VStream = context.v_findOrCreateObject( [ "apiPath" : self.apiPath ] )
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
            self.persistentStore.mainContext.v_performBlock() { context in
                self.results = persistentStreamItemIDs.flatMap {
                    context.objectWithID($0) as? VStreamItem
                }
                completion()
            }
        }
    }
    
    func fetchLocalResults(preloadedStreamObjectID: NSManagedObjectID) -> [AnyObject] {
        return persistentStore.mainContext.v_performBlockAndWait() { context in
            guard let stream = context.objectWithID(preloadedStreamObjectID) as? VStream else {
                return []
            }
            let persistentStreamItemPointers = stream.streamItemPointers.array
            let persistentStreamItemIDs = persistentStreamItemPointers.flatMap { ($0 as? VStreamItemPointer)?.streamItem.objectID }
            
            return persistentStreamItemIDs.flatMap {
                context.objectWithID($0) as? VStreamItem
            }
        }
    }
}

class StreamFetcherOperation: FetcherOperation {
    
    let apiPath: String
    let paginator: NumericPaginator
    
    init( apiPath: String ) {
        self.apiPath = apiPath
        self.paginator = StreamPaginator(apiPath: apiPath)!
    }
    
    override func main() {
        self.results = persistentStore.mainContext.v_performBlockAndWait() { context in
            let fetchRequest = NSFetchRequest(entityName: VStreamItemPointer.v_entityName())
            fetchRequest.sortDescriptors = [ NSSortDescriptor(key: "displayOrder", ascending: true) ]
            
            let streamItemPredicate = NSPredicate(format: "streamParent.apiPath == %@", self.apiPath)
            let paginationPredicate = self.paginator.paginatorPredicate
            fetchRequest.predicate = paginationPredicate + streamItemPredicate
            
            let results = context.v_executeFetchRequest( fetchRequest ) as [VStreamItemPointer]
            return results.map { $0.streamItem }
        }
    }
}
