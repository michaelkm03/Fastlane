//
//  SequenceLikersOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 12/21/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

final class SequenceLikersOperation: FetcherOperation, PaginatedOperation {
    
    let paginator: StandardPaginator
    
    private var sequenceID: String
    
    required init( sequenceID: String, paginator: StandardPaginator = StandardPaginator() ) {
        self.sequenceID = sequenceID
        self.paginator = paginator
        super.init()
        
        if !localFetch {
            let request = SequenceLikersRequest(sequenceID: sequenceID, paginator: paginator)
            SequenceLikersRemoteOperation(request: request).before(self).queue()
        }
    }
    
    required convenience init(operation: SequenceLikersOperation, paginator: StandardPaginator) {
        self.init(sequenceID: operation.sequenceID, paginator: paginator)
    }
    
    override func main() {
        return persistentStore.mainContext.v_performBlockAndWait() { context in
            let fetchRequest = NSFetchRequest(entityName: VSequenceLiker.v_entityName())
            fetchRequest.sortDescriptors = [ NSSortDescriptor(key: "displayOrder", ascending: true) ]
            let predicate = NSPredicate(format: "sequence.remoteId = %@", self.sequenceID )
            fetchRequest.predicate = predicate + self.paginator.paginatorPredicate
            let fetchResults: [VSequenceLiker] = context.v_executeFetchRequest( fetchRequest )
            self.results = fetchResults.flatMap { $0.user }
        }
    }
}
