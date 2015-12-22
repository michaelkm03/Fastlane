//
//  PersistentStoreDebugger.swift
//  victorious
//
//  Created by Patrick Lynch on 12/22/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation

@objc class PersistentStoreDebugger: NSObject {
    
    let persistentStore: PersistentStoreType
    
    init( persistentStore: PersistentStoreType = MainPersistentStore() ) {
        self.persistentStore = persistentStore
    }
    
    func debug_printStreams() {
        self.persistentStore.mainContext.v_performBlockAndWait() { context in
            let allStreams: [VStream] = context.v_findObjects(limit: 0)
            print( "\n\nThere are \(allStreams.count) streams." )
            for stream in allStreams {
                print( "\t- \"\(stream.apiPath)\" :: \(stream.streamItems.count) stream items" )
            }
            
            let allSequences: [VSequence] = context.v_findObjects(limit: 0)
            print( "\n\nThere are \(allSequences.count) sequences." )
        }
    }
}