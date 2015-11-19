//
//  StreamOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 11/16/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

class StreamOperation: RequestOperation<StreamRequest> {
    
    private let persistentStore = PersistentStore()
    
    init?( apiPath: String, sequenceID: String? = nil, pageNumber: Int = 1, itemsPerPage: Int = 15) {
        super.init( request: StreamRequest(apiPath: apiPath, sequenceID: sequenceID, pageNumber: pageNumber, itemsPerPage: itemsPerPage)! )
    }
    
    override init( request: StreamRequest ) {
        super.init(request: request)
    }
    
    var nextPageOperation: StreamOperation?
    var previousPageOperation: StreamOperation?
    
    override func onResponse(response: StreamRequest.ResultType) {
        let stream = response.results
        
        persistentStore.syncFromBackground() { context in
            let uniqueElements = [ "apiPath" : self.request.apiPath ]
            let persistentStream: VStream = context.findOrCreateObject( uniqueElements )
            persistentStream.populate( fromSourceModel: stream )
            
            dispatch_sync( dispatch_get_main_queue() ) {
                if let nextPageRequest = response.nextPage {
                    self.nextPageOperation = StreamOperation( request: nextPageRequest )
                }
                if let previousPageRequest = response.previousPage {
                    self.previousPageOperation = StreamOperation( request: previousPageRequest )
                }
            }
            context.saveChanges()
        }
    }
}

class SequenceCommentsOperation: RequestOperation<SequenceCommentsRequest> {
    
    private let persistentStore = PersistentStore()
    
    init( sequenceID: Int64, pageNumber: Int = 1, itemsPerPage: Int = 15) {
        super.init( request: SequenceCommentsRequest(sequenceID: sequenceID, pageNumber: pageNumber, itemsPerPage: itemsPerPage) )
    }
    
    override init( request: SequenceCommentsRequest ) {
        super.init(request: request)
    }
    
    var nextPageOperation: SequenceCommentsOperation?
    var previousPageOperation: SequenceCommentsOperation?
    
    override func onResponse(response: SequenceCommentsRequest.ResultType) {
        
        persistentStore.syncFromBackground() { context in
            let sequence: VSequence = context.findObjects( [ "remoteId" : Int(self.request.sequenceID) ] ).first!
            for comment in response.results {
                let persistentComment: VComment = context.findOrCreateObject( [ "remoteId" : Int(comment.commentID) ] )
                persistentComment.populate( fromSourceModel: comment )
                persistentComment.sequence = sequence
                persistentComment.sequenceId = sequence.remoteId
                persistentComment.userId = sequence.user?.remoteId
            }
            
            dispatch_sync( dispatch_get_main_queue() ) {
                if let nextPageRequest = response.nextPage {
                    self.nextPageOperation = SequenceCommentsOperation( request: nextPageRequest )
                }
                if let previousPageRequest = response.previousPage {
                    self.previousPageOperation = SequenceCommentsOperation( request: previousPageRequest )
                }
            }
            
            context.saveChanges()
        }
    }
}
