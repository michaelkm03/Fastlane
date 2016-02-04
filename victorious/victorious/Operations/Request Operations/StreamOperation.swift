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
            
            // Parse stream
            let stream: VStream = context.v_findOrCreateObject( [ "apiPath" : self.apiPath ] )
            stream.populate(fromSourceModel: sourceStream)
            
            guard let sourceStreamItems = sourceStream.items else {
                self.results = []
                completion()
                return
            }
            
            // Assign display order to stream children that were parsed in `populate` method above
            var displayOrder = self.request.paginator.displayOrderCounterStart
            let predicate = NSPredicate() { (object, bindings) in
                guard let streamChild = object as? VStreamChild else {
                    return false
                }
                return sourceStreamItems.contains() { streamChild.streamItem.remoteId == $0.streamItemID }
            }
            let parsedStreamChildren = stream.streamChildren.filteredOrderedSetUsingPredicate( predicate )
            for object in parsedStreamChildren {
                guard let child = object as? VStreamChild else {
                    continue
                }
                child.displayOrder = displayOrder++
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
            let fetchRequest = NSFetchRequest(entityName: VStreamChild.v_entityName())
            fetchRequest.sortDescriptors = [ NSSortDescriptor(key: "displayOrder", ascending: true) ]
            
            let streamItemPredicate = NSPredicate(format: "streamParent.apiPath == %@", self.apiPath)
            let paginationPredicate = self.request.paginator.paginatorPredicate()
            fetchRequest.predicate = paginationPredicate + streamItemPredicate
            
            let results = context.v_executeFetchRequest( fetchRequest ) as [VStreamChild]
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
            let fetchRequest = NSFetchRequest(entityName: VStreamChild.v_entityName())
            fetchRequest.sortDescriptors = [ NSSortDescriptor(key: "displayOrder", ascending: true) ]
            
            let streamItemPredicate = NSPredicate(format: "streamParent.apiPath == %@", self.apiPath)
            let paginationPredicate = self.paginator.paginatorPredicate()
            fetchRequest.predicate = paginationPredicate + streamItemPredicate
            
            let results = context.v_executeFetchRequest( fetchRequest ) as [VStreamChild]
            return results.map { $0.streamItem }
        }
    }
}
