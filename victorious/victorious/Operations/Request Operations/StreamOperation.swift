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
    private(set) var resultCount: Int?
    
    private(set) var results = [VStreamItem]()
    
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
    
    private func onError( error: NSError, completion:(()->())? ) {
        if error.code == RequestOperation.errorCodeNoNetworkConnection {
            self.results = loadPersistentItems()
            self.resultCount = self.results.count
        }
        completion?()
    }
    
    private func onComplete( stream: StreamRequest.ResultType, completion:()->() ) {
       persistentStore.asyncFromBackground() { context in
            let persistentStream: VStream = context.findOrCreateObject( [ "apiPath" : self.apiPath ] )
            let streamItems = VStreamItem.parseStreamItems(stream.items, context: context)
            persistentStream.addObjects( streamItems, to: "streamItems" )
            context.saveChanges()
            completion()
        }
        
        self.results = loadPersistentItems()
        self.resultCount = self.results.count
        completion()
    }
    
    private func loadPersistentItems() -> [VStreamItem] {
        return persistentStore.sync() { context in
            let uniqueProps = [ "streams" : [ "apiPath" : self.apiPath] ]
            let pagination = PersistentStorePagination(
                itemsPerPage: self.request.paginator.itemsPerPage,
                pageNumber: self.request.paginator.pageNumber
            )
            return context.findObjects( uniqueProps, pagination: pagination )
        }
    }
}
