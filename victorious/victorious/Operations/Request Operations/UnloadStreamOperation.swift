//
//  UnloadStreamOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 12/23/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

/// Deletes all the stream items in a stream, but leaves the stream unmodified
class UnloadStreamItemOperation: Operation {
    
    private let streamID: String
    
    let persistentStore: PersistentStoreType = PersistentStoreSelector.mainPersistentStore
    
    init( streamID: String) {
        self.streamID = streamID
    }
    
    override func main() {
        persistentStore.backgroundContext.v_performBlock() { context in
            guard let stream: VStream = context.v_findObjects([ "remoteId" : self.streamID ]).first,
                let streamItems = stream.streamItems.array as? [VStreamItem]
                where streamItems.count > 0 else {
                    return
            }
            for streamItem in streamItems {
                context.deleteObject( streamItem )
            }
            stream.v_removeAllObjects(from: "streamItems")
            context.v_save()
        }
    }
}
