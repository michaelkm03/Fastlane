//
//  PollResultSummaryBySequenceRemoteOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 3/3/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

final class PollResultSummaryBySequenceRemoteOperation: RemoteFetcherOperation, RequestOperation {
    
    let request: PollResultSummaryRequest!
    
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
    
    private func onComplete( pollResults: PollResultSummaryRequest.ResultType) {
        
        persistentStore.createBackgroundContext().v_performBlockAndWait { context in
            var displayOrder = self.request.paginator.displayOrderCounterStart
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
                persistentResult.displayOrder = displayOrder
                displayOrder += 1
            }
            context.v_save()
        }
    }
}
