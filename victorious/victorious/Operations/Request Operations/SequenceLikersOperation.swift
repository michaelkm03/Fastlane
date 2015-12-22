//
//  SequenceLikersOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 12/21/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

final class SequenceLikersOperation: RequestOperation, PaginatedOperation, ResultsOperation {
    
    let request: SequenceLikersRequest
    var resultCount: Int?
    
    private var sequenceID: Int64
    
    private(set) var results: [AnyObject]?
    
    required init( request: SequenceLikersRequest ) {
        self.sequenceID = request.sequenceID
        self.request = request
    }
    
    convenience init( sequenceID: Int64 ) {
        self.init( request: SequenceLikersRequest(sequenceID: sequenceID) )
    }
    
    override func main() {
        executeRequest( request, onComplete: self.onComplete, onError: self.onError )
    }
    
    private func onError( error: NSError, completion:(()->()) ) {
        if error.code == RequestOperation.errorCodeNoNetworkConnection {
            let results = loadPersistentData()
            self.results = results
            self.resultCount = results.count
            
        } else {
            self.resultCount = 0
        }
        completion()
    }
    
    private func onComplete( users: SequenceLikersRequest.ResultType, completion:()->() ) {
        
        persistentStore.backgroundContext.v_performBlock() { context in
            
            let sequence: VSequence = context.v_findOrCreateObject(["remoteId" : String(self.sequenceID) ])
            
            for user in users {
                let uniqueElements = [ "remoteId" : NSNumber( longLong: user.userID ) ]
                let persistentUser: VUser = context.v_findOrCreateObject( uniqueElements )
                persistentUser.populate(fromSourceModel: user)
                persistentUser.v_addObject( sequence, to: "likedSequences" )
            }
            
            context.v_save()
            
            dispatch_async( dispatch_get_main_queue() ) {
                let results = self.loadPersistentData()
                self.results = results
                self.resultCount = results.count
                completion()
            }
        }
    }
    
    private func loadPersistentData() -> [VUser] {
        return persistentStore.mainContext.v_performBlockAndWait() { context in
            let uniqueProps = [ "likedSequences" : [ "remoteId" : String(self.sequenceID) ] ]
            let pagination = PersistentStorePagination(
                itemsPerPage: self.request.paginator.itemsPerPage,
                pageNumber: self.request.paginator.pageNumber
            )
            return context.v_findObjects( uniqueProps, pagination: pagination )
        }
    }
}
