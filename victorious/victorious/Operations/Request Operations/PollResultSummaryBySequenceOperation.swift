//
//  PollResultSummaryBySequenceOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 12/1/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

final class PollResultSummaryBySequenceOperation: RequestOperation, PaginatedOperation {
    
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
        
        storedBackgroundContext = persistentStore.createBackgroundContext().v_performBlockAndWait() { context in
            
            guard let sequence: VSequence = context.v_findObjects( ["remoteId" : self.sequenceID] ).first else {
                return context
            }
            for pollResult in pollResults {
                var uniqueElements = [String : AnyObject]()
                if let answerID = pollResult.answerID {
                    uniqueElements[ "answerId" ] = answerID
                } else {
                    continue
                }
                uniqueElements[ "sequenceId" ] = self.sequenceID
                
                let persistentResult: VPollResult = context.v_findOrCreateObject( uniqueElements )
                persistentResult.populate(fromSourceModel:pollResult)
                persistentResult.sequence = sequence
            }
            
            context.v_save()
            completion()
            return context
        }
    }
}
