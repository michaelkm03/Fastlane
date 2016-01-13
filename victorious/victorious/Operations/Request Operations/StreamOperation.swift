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
    
    private(set) var results: [AnyObject]?
    private(set) var didResetResults: Bool = false
    
    private let apiPath: String
    
    required init( request: StreamRequest ) {
        self.apiPath = request.apiPath
        self.request = request
    }
    
    convenience init( apiPath: String, sequenceID: String? = nil) {
        self.init( request: StreamRequest(apiPath: apiPath, sequenceID: sequenceID)! )
    }
    
    override func main() {
        requestExecutor.executeRequest( request, onComplete: self.onComplete, onError:self.onError )
    }
    
    func onError( error: NSError, completion: ()->() ) {
        if error.code == RequestOperation.errorCodeNoNetworkConnection {
            self.results = fetchResults()
        }
        completion()
    }
    
    func onComplete( stream: StreamRequest.ResultType, completion:()->() ) {
        
        // Make changes on background queue
        storedBackgroundContext = persistentStore.createBackgroundContext().v_performBlock() { context in
            
            // Parse stream
            let persistentStream: VStream = context.v_findOrCreateObject( [ "apiPath" : self.apiPath ] )
            persistentStream.populate(fromSourceModel: stream)
            
            // Parse stream items
            var displayOrder = (self.request.paginator.pageNumber - 1) * self.request.paginator.itemsPerPage
            let streamItems = VStreamItem.parseStreamItems(fromStream: stream, inManagedObjectContext: context)
            for streamItem in streamItems {
                streamItem.displayOrder = displayOrder++
                streamItem.streamId = stream.streamID
            }
            persistentStream.v_addObjects(streamItems, to: "streamItems")
            context.v_save()
            
            // Reload results from main queue
            self.results = self.fetchResults()
            completion()
        }
    }
    
    func fetchResults() -> [VStreamItem] {
        return persistentStore.mainContext.v_performBlockAndWait() { context in
            let fetchRequest = NSFetchRequest(entityName: VStreamItem.v_entityName())
            fetchRequest.sortDescriptors = [ NSSortDescriptor(key: "displayOrder", ascending: true) ]
            let predicate = NSPredicate(
                v_format: "ANY self.streams.apiPath = %@",
                v_argumentArray: [ self.apiPath ],
                v_paginator: self.request.paginator
            )
            fetchRequest.predicate = predicate
            return context.v_executeFetchRequest( fetchRequest )
        }
    }
}
