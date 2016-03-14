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
class UnloadStreamItemOperation: FetcherOperation {
    
    private let streamID: String
    
    init( streamID: String) {
        self.streamID = streamID
    }
    
    override func main() {
        persistentStore.createBackgroundContext().v_performBlockAndWait() { context in
            let uniqueInfo = [ "remoteId" : self.streamID ]
            guard let stream: VStream = context.v_findObjects(uniqueInfo).first else {
                    return
            }
            let streamItems = stream.streamItems
            guard !streamItems.isEmpty else {
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
