//
//  PollResultSummaryBySequenceOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 12/1/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

final class PollResultSummaryBySequenceOperation: RequestOperation {
    
    let request: PollResultSummaryRequest
    
    private let sequenceID: String
    
    required init( request: PollResultSummaryRequest ) {
        self.sequenceID = request.sequenceID!
        self.request = request
    }
    
    convenience init( sequenceID: String ) {
        self.init( request: PollResultSummaryRequest(sequenceID: sequenceID) )
    }
    
    override func main() {
        requestExecutor.executeRequest( request, onComplete: self.onComplete, onError: nil )
    }
    
    private func onComplete( pollResults: PollResultSummaryRequest.ResultType, completion:()->() ) {
        
        storedBackgroundContext = persistentStore.createBackgroundContext().v_performBlock { context in
            for pollResult in pollResults {
                // Populate a persistent VPollResult object
                guard let answerID = pollResult.answerID else {
                    continue
                }
                let uniqueElements: [String : AnyObject] = [
                    "answerId" : NSNumber(integer: answerID),
                    "sequenceId" : self.sequenceID
                ]
                
                let persistentResult: VPollResult = context.v_findOrCreateObject( uniqueElements )
                persistentResult.populate(fromSourceModel:pollResult)
            }
            context.v_save()
            
            dispatch_async(dispatch_get_main_queue()) {
                self.results = self.fetchResults()
                completion()
            }
        }
    }
    
    private func fetchResults() -> [AnyObject] {
        return persistentStore.mainContext.v_performBlockAndWait() { context in
            let fetchRequest = NSFetchRequest(entityName: VPollResult.v_entityName())
            let predicate = NSPredicate(format: "sequenceId == %@", argumentArray: [self.sequenceID])
            fetchRequest.predicate = predicate
            return context.v_executeFetchRequest(fetchRequest)
        }
    }
}
