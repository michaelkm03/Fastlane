//
//  PollResultSummaryBySequenceOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 12/1/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

final class PollResultSummaryBySequenceOperation: FetcherOperation {
    
    let paginator: StandardPaginator
    
    private var sequenceID: String
    
    required init( sequenceID: String, paginator: StandardPaginator = StandardPaginator() ) {
        self.sequenceID = sequenceID
        self.paginator = paginator
        super.init()
        
        if !localFetch {
            let request = PollResultSummaryRequest(sequenceID: sequenceID, paginator: paginator)
            PollResultSummaryBySequenceRemoteOperation(request: request).before(self).queue()
        }
    }
    
    required convenience init(operation: PollResultSummaryBySequenceOperation, paginator: StandardPaginator) {
        self.init(sequenceID: operation.sequenceID, paginator: paginator)
    }
    
    override func main() {
        persistentStore.mainContext.v_performBlockAndWait() { context in
            let fetchRequest = NSFetchRequest(entityName: VPollResult.v_entityName())
            let predicate = NSPredicate(format: "sequenceId == %@", self.sequenceID)
            fetchRequest.predicate = predicate + self.paginator.paginatorPredicate
            self.results = context.v_executeFetchRequest(fetchRequest)
        }
    }
}
