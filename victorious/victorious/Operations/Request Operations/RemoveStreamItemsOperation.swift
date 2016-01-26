//
//  RemoveStreamItemOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 12/23/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

class RemoveStreamItemOperation: Operation {
    
    private let streamItemIDs: [String]
    
    let persistentStore: PersistentStoreType = PersistentStoreSelector.defaultPersistentStore
    
    convenience init(streamItemID: String) {
        self.init(streamItemIDs: [streamItemID])
    }
    
    required init(streamItemIDs: NSArray) {
        self.streamItemIDs = streamItemIDs as? [String] ?? []
    }
    
    override func main() {
        persistentStore.createBackgroundContext().v_performBlockAndWait() { context in
            
            if self.streamItemIDs.isEmpty {
                return
            }
            
            for streamItemID in self.streamItemIDs {
                if let streamItem: VStreamItem = context.v_findObjects([ "remoteId" : streamItemID ]).first,
                    let streamID = streamItem.streamId,
                     let stream: VStream = context.v_findObjects([ "remoteId" : streamID ]).first {
                        stream.v_removeObject( streamItem, from: "streamItems" )
                        context.deleteObject( streamItem )
                }
            }
            context.v_save()
        }
    }
}
