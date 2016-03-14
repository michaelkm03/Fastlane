//
//  SequenceRepostersOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 11/23/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

final class SequenceRepostersOperation: FetcherOperation, PaginatedOperation {
    
    let paginator: StandardPaginator
    
    private var sequenceID: String
    
    required init( sequenceID: String, paginator: StandardPaginator = StandardPaginator() ) {
        self.sequenceID = sequenceID
        self.paginator = paginator
        super.init()
        
        if !localFetch {
            let request = SequenceRepostersRequest(sequenceID: sequenceID, paginator: paginator)
            SequenceRepostersRemoteOperation(request: request).before(self).queue()
        }
    }
    
    required convenience init(operation: SequenceRepostersOperation, paginator: StandardPaginator) {
        self.init(sequenceID: operation.sequenceID, paginator: paginator)
    }
    
    override func main() {
        persistentStore.mainContext.v_performBlockAndWait() { context in
            let fetchRequest = NSFetchRequest(entityName: VUser.v_entityName())
            let predicate = NSPredicate(format: "ANY repostedSequences.remoteId = %@", self.sequenceID)
            fetchRequest.predicate = predicate
            self.results = context.v_executeFetchRequest(fetchRequest)
        }
    }
}
