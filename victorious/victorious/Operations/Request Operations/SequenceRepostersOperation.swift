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
    }
    
    required convenience init(operation: SequenceRepostersOperation, paginator: StandardPaginator) {
        self.init(sequenceID: operation.sequenceID, paginator: paginator)
    }
    
    override func start() {
        if !localFetch {
            let request = SequenceRepostersRequest(sequenceID: sequenceID, paginator: paginator)
            SequenceRepostersRemoteOperation(request: request).before(self).queue()
        }
        super.start()
    }
    
    override func main() {
        
        // TODO:
        /*if let objectIDs = dependencies.flatMap { $0 as? PrefetchedResultsOperation }.first {
            // Reload objectIDs in main context
        } else {
            // Fetch request
        }*/

        // TOOD: Make sure this works
        
        persistentStore.mainContext.v_performBlockAndWait() { context in
            let fetchRequest = NSFetchRequest(entityName: VUser.v_entityName())
            let predicate = NSPredicate(format: "ANY resposedSequences.remoteId = %@", self.sequenceID)
            fetchRequest.predicate = predicate + self.paginator.paginatorPredicate
            self.results = context.v_executeFetchRequest(fetchRequest)
        }
    }
}
