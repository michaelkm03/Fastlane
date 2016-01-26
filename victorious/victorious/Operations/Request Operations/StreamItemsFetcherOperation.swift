//
//  StreamItemsFetcherOperation.swift
//  victorious
//
//  Created by Tian Lan on 1/25/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

class StreamItemsFetcherOperation: FetcherOperation {
    
    let streamID: String
    
    init( streamID: String ) {
        self.streamID = streamID
    }
    
    override func main() {
        self.results = persistentStore.mainContext.v_performBlockAndWait() { context in
            let fetchRequest = NSFetchRequest(entityName: VStreamItem.v_entityName())
            fetchRequest.sortDescriptors = [ NSSortDescriptor(key: "displayOrder", ascending: true) ]
            fetchRequest.predicate = NSPredicate(format: "ANY self.streams.remoteId = %@", self.streamID )
            let results = context.v_executeFetchRequest( fetchRequest ) as [VStreamItem]
            return results
        }
    }
}
