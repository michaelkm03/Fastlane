//
//  StreamItemsFetcherOperation.swift
//  victorious
//
//  Created by Tian Lan on 1/25/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

class StreamItemsFetcherOperation: FetcherOperation {
    
    let streamObjectID: NSManagedObjectID
    
    init( streamObjectID: NSManagedObjectID ) {
        self.streamObjectID = streamObjectID
    }
    
    override func main() {
        persistentStore.mainContext.v_performBlockAndWait() { context in
            guard let stream = context.objectWithID(self.streamObjectID) as? VStream else {
                return
            }
            self.results = stream.streamItems
        }
    }
}
