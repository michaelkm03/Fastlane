
//
//  DeleteSequenceOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 12/15/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

class DeleteSequenceOperation: RequestOperation {
    
    private let sequenceID: String
    
    var request: DeleteSequenceRequest
    
    init( sequenceID: String ) {
        self.request = DeleteSequenceRequest(sequenceID: sequenceID)
        self.sequenceID = sequenceID
    }
    
    override func main() {
        executeRequest( self.request )
    }
    
    func onComplete( stream: DeleteSequenceRequest.ResultType, completion:()->() ) {
        persistentStore.backgroundContext.v_performBlock() { context in
            guard let sequence: VSequence = context.v_findObjects([ "remoteId" : String(self.sequenceID) ]).first else {
                completion()
                return
            }
            
            context.deleteObject( sequence )
            context.v_save()
            completion()
        }
    }
}

class RemoteStreamItemOperation: Operation {
    
    private let streamItemID: String
    
    let persistentStore: PersistentStoreType = MainPersistentStore()
    
    init( streamItemID: String) {
        self.streamItemID = streamItemID
    }
    
    override func main() {
        persistentStore.backgroundContext.v_performBlock() { context in
            guard let streamItem: VStreamItem = context.v_findObjects([ "remoteId" : self.streamItemID ]).first,
                let streamID = streamItem.streamId,
                let stream: VStream = context.v_findObjects([ "remoteId" : streamID ]).first else {
                    return
            }
            
            stream.v_removeObject( streamItem, from: "streamItems" )
            context.v_save()
        }
    }
}

/// Deletes all the stream items in a stream, but leaves the stream unmodified
class UnloadStreamItemOperation: Operation {
    
    private let streamID: String
    
    let persistentStore: PersistentStoreType = MainPersistentStore()
    
    init( streamID: String) {
        self.streamID = streamID
    }
    
    override func main() {
        persistentStore.backgroundContext.v_performBlock() { context in
            guard let stream: VStream = context.v_findObjects([ "remoteId" : self.streamID ]).first else {
                return
            }
            
            stream.v_removeAllObjects(from: "streamItems")
            context.v_save()
        }
    }
}
