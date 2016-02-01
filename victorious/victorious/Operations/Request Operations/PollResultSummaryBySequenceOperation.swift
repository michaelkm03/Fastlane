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
            
            guard let sequence: VSequence = context.v_findObjects( ["remoteId" : self.sequenceID] ).first else {
                return
            }
            
            let persistentPollResults = NSSet(array: pollResults.flatMap {
                // Populate a persistent VPollResult object
                guard let answerID = $0.answerID else {
                    return nil
                }
                let uniqueElements: [String : AnyObject] = [
                    "answerId" : NSNumber(integer: answerID),
                    "sequenceId" : self.sequenceID
                ]
                
                let persistentResult: VPollResult = context.v_findOrCreateObject( uniqueElements )
                persistentResult.populate(fromSourceModel:$0)
                
                return persistentResult
                })
            
            let uniqueInfo = ["sequence" : sequence, "pollResults" : persistentPollResults]
            let _: VSequencePollResults = context.v_findOrCreateObject(uniqueInfo)
            
            context.v_save()
            dispatch_async(dispatch_get_main_queue()) {
                self.results = self.fetchResults()
                completion()
            }
        }
    }
    
    private func fetchResults() -> [AnyObject] {
        return persistentStore.mainContext.v_performBlockAndWait() { context in
            guard let sequence: VSequence = context.v_findObjects( ["remoteId" : self.sequenceID] ).first else {
                return []
            }
            let fetchRequest = NSFetchRequest(entityName: VSequencePollResults.v_entityName())
            let predicate = NSPredicate(format: "sequence.remoteId == %@", argumentArray: [ sequence.remoteId])
            fetchRequest.predicate = predicate
            let result = (context.v_executeFetchRequest(fetchRequest).first as? VSequencePollResults)!
            
            return result.pollResults.flatMap { $0 }
        }
    }
}
