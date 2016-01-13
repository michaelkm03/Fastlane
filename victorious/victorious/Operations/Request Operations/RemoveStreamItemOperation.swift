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
class RemoveStreamItemOperation: Operation {
    
    private let streamItemID: String
    
    let persistentStore: PersistentStoreType = PersistentStoreSelector.defaultPersistentStore
    
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
            context.deleteObject( streamItem )
            context.v_save()
        }
    }
}
