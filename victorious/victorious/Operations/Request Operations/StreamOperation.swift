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
    
    func onComplete( stream: StreamRequest.ResultType, completion:()->() ) {
        
        // Make changes on background queue
        storedBackgroundContext = persistentStore.createBackgroundContext().v_performBlock() { context in
            
            // Parse stream
            let persistentStream: VStream = context.v_findOrCreateObject( [ "apiPath" : self.apiPath ] )
            persistentStream.populate(fromSourceModel: stream)
            
            // Parse stream items
            var displayOrder = self.request.paginator.displayOrderCounterStart
            let streamItems = VStreamItem.parseStreamItems(fromStream: stream, inManagedObjectContext: context)
            for streamItem in streamItems {
                streamItem.displayOrder = displayOrder++
                streamItem.streamId = stream.streamID
            }
            persistentStream.v_addObjects(streamItems, to: "streamItems")
            context.v_save()
            completion()
        }
    }
    
    // MARK: - PaginatedOperation
    
    internal(set) var results: [AnyObject]?
    
    func fetchResults() -> [AnyObject] {
        return persistentStore.mainContext.v_performBlockAndWait() { context in
            let fetchRequest = NSFetchRequest(entityName: VStreamItem.v_entityName())
            fetchRequest.sortDescriptors = [ NSSortDescriptor(key: "displayOrder", ascending: true) ]
            let predicate = NSPredicate(
                vsdk_format: "ANY self.streams.apiPath = %@",
                vsdk_argumentArray: [ self.apiPath ],
                vsdk_paginator: self.request.paginator
            )
            fetchRequest.predicate = predicate
            return context.v_executeFetchRequest( fetchRequest )
        }
    }
    
    func clearResults() {
        persistentStore.createBackgroundContext().v_performBlockAndWait() { context in
            guard let persistentStream: VStream = context.v_findObjects( [ "apiPath" : self.apiPath ] ).first else {
                return
            }
            for streamItem in persistentStream.streamItems.array as? [VStreamItem] ?? [] {
                context.deleteObject( streamItem )
            }
            context.v_save()
        }
    }
}
