//
//  StreamOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 12/4/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

final class StreamOperation: RequestOperation, PaginatedOperation {
    
    let request: StreamRequest
    
    private let apiPath: String
    
    private var persistentStreamItemIDs: [NSManagedObjectID]?
    
    required init( request: StreamRequest ) {
        self.apiPath = request.apiPath
        self.request = request
    }
    
    convenience init( apiPath: String, sequenceID: String? = nil) {
        self.init( request: StreamRequest(apiPath: apiPath, sequenceID: sequenceID)! )
    }
    
    override func main() {
        requestExecutor.executeRequest( request, onComplete: self.onComplete, onError:nil )
    }
    
    func onComplete( sourceStream: StreamRequest.ResultType, completion:()->() ) {
        
        // Make changes on background queue
        storedBackgroundContext = persistentStore.createBackgroundContext().v_performBlock() { context in
            
            // FIXME: This is a hack to refresh streams.  `PaginatedDataSource` should really handle
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
                for object in persistentStreamItemPointers {
                    guard let pointer = object as? VStreamItemPointer else {
                        continue
                    }
                    pointer.displayOrder = displayOrder++
                }
                
            } else {
                persistentStreamItemPointers = []
            }
            
            context.v_save()
            
            let persistentStreamItemIDs = persistentStreamItemPointers.flatMap { ($0 as? VStreamItemPointer)?.streamItem.objectID }
            self.persistentStore.mainContext.v_performBlock() { context in
                
                if let stream: VStream = context.v_findObjects( [ "apiPath" : self.apiPath ] ).first {
                    print( "\n\nStream: \((stream.apiPath! as NSString).substringToIndex(20))... now has \(stream.streamItemPointers.count) stream item pointers.")
                }
                
                defer { completion() }
                guard persistentStreamItemPointers.count > 0 else {
                    self.results = []
                    return
                }
                
                var streamItems = [VStreamItem]()
                for id in persistentStreamItemIDs {
                    if let streamItem = context.objectWithID(id) as? VStreamItem {
                        streamItems.append( streamItem )
                    }
                }
                self.results = streamItems
            }
        }
    }
    
    func fetchResults() -> [AnyObject] {
        return persistentStore.mainContext.v_performBlockAndWait() { context in
            let fetchRequest = NSFetchRequest(entityName: VStreamItemPointer.v_entityName())
            fetchRequest.sortDescriptors = [ NSSortDescriptor(key: "displayOrder", ascending: true) ]
            
            let streamItemPredicate = NSPredicate(format: "streamParent.apiPath == %@", self.apiPath)
            let paginationPredicate = self.request.paginator.paginatorPredicate
            fetchRequest.predicate = paginationPredicate + streamItemPredicate
            
            let results = context.v_executeFetchRequest( fetchRequest ) as [VStreamItemPointer]
            return results.map { $0.streamItem }
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
