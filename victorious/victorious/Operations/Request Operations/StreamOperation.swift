//
//  StreamOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 12/4/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

final class StreamOperation: RequestOperation, PaginatedOperation, ResultsOperation {
    
    let request: StreamRequest
    private(set) var resultCount: Int?
    
    private(set) var results: [AnyObject]?
    
    private let apiPath: String
    
    required init( request: StreamRequest ) {
        self.apiPath = request.apiPath
        self.request = request
    }
    
    convenience init( apiPath: String, sequenceID: Int64? = nil) {
        self.init( request: StreamRequest(apiPath: apiPath, sequenceID: sequenceID)! )
    }
    
    override func main() {
        executeRequest( request, onComplete: self.onComplete, onError:self.onError )
    }
    
    private func onError( error: NSError, completion: ()->() ) {
        if error.code == RequestOperation.errorCodeNoNetworkConnection {
            let results = loadPersistentItems()
            self.results = results
            self.resultCount = results.count
        
        } else {
            self.resultCount = 0
        }
        completion()
    }
    
    private func onComplete( stream: StreamRequest.ResultType, completion:()->() ) {
        persistentStore.backgroundContext.v_performBlockAndWait() { context in
            let persistentStream: VStream = context.v_findOrCreateObject( [ "apiPath" : self.apiPath ] )
            let streamItems = VStreamItem.parseStreamItems(stream.items, managedObjectContext: context)
            persistentStream.v_addObjects( streamItems, to: "streamItems" )
            context.v_save()
        }
        
        let results = loadPersistentItems()
        self.results = results
        self.resultCount = results.count
        
        completion()
    }
    
    private func loadPersistentItems() -> [VStreamItem] {
        return persistentStore.mainContext.v_performBlockAndWait() { context in
            let uniqueProps = [ "streams" : [ "apiPath" : self.apiPath] ]
            let pagination = PersistentStorePagination(
                itemsPerPage: self.request.paginator.itemsPerPage,
                pageNumber: self.request.paginator.pageNumber
            )
            return context.v_findObjects( uniqueProps, pagination: pagination )
        }
    }
}
