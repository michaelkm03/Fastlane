//
//  RemoveStreamItemOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 12/23/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

/// Remotes a stream item from the stream and deletes it
// TODO: Do we still need this?
class RemoveStreamItemOperation: Operation {
    
    private let streamItemID: String
    
    let persistentStore: PersistentStoreType = PersistentStoreSelector.mainPersistentStore
    
    init( streamItemID: String) {
        self.streamItemID = streamItemID
    }
    
    override func main() {
        persistentStore.createBackgroundContext().v_performBlockAndWait() { context in
            guard let streamItem: VStreamItem = context.v_findObjects([ "remoteId" : self.streamItemID ]).first,
                let streamID = streamItem.streamId,
                let stream: VStream = context.v_findObjects([ "remoteId" : streamID ]).first else {
                    return
            }
            
            stream.v_removeObject( streamItem, from: "streamItems" )
            context.deleteObject( streamItem )
            context.v_save()
        }
    }
}
