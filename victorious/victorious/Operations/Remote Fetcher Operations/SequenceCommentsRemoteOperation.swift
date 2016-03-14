//
//  SequenceCommentsRemoteOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 3/3/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

final class SequenceCommentsOperation: FetcherOperation, PaginatedOperation {
    
    let paginator: StandardPaginator
    let sequenceID: String
    
    required init(sequenceID: String, paginator: StandardPaginator = StandardPaginator()) {
        self.paginator = paginator
        self.sequenceID = sequenceID
        super.init()
        
        if !localFetch {
            let request = SequenceCommentsRequest(sequenceID: sequenceID, paginator: paginator)
            SequenceCommentsRemoteOperation(request: request).before(self).queue()
        }
    }
    
    required convenience init(operation: SequenceCommentsOperation, paginator: StandardPaginator) {
        self.init(sequenceID: operation.sequenceID, paginator: paginator)
    }
    
    override func main() {
        persistentStore.mainContext.v_performBlockAndWait() { context in
            let fetchRequest = NSFetchRequest(entityName: VComment.v_entityName())
            fetchRequest.sortDescriptors = [ NSSortDescriptor(key: "displayOrder", ascending: true) ]
            let predicate = NSPredicate(format: "sequence.remoteId == %@", self.sequenceID )
            let paginatorPredicate = self.paginator.paginatorPredicate
            fetchRequest.predicate = predicate + paginatorPredicate
            let fetchResults = context.v_executeFetchRequest( fetchRequest ) as [VComment]
            self.results =  fetchResults
        }
    }
}
