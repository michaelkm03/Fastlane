//
//  PollResultSummaryBySequenceOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 12/1/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

final class PollResultSummaryBySequenceOperation: RequestOperation, PageableOperationType {
    
    var currentRequest: PollResultSummaryRequest
    private let sequenceID: Int64
    
    required init( request: PollResultSummaryRequest ) {
        self.sequenceID = request.sequenceID!
        self.currentRequest = request
    }
    
    convenience init( sequenceID: Int64, pageNumber: Int = 1, itemsPerPage: Int = 15) {
        self.init( request: PollResultSummaryRequest(sequenceID: sequenceID) )
    }
    
    override func main() {
        executeRequest( currentRequest, onComplete: self.onComplete )
    }
    
    private func onComplete( pollResults: PollResultSummaryRequest.ResultType, completion:()->() ) {
        
        persistentStore.asyncFromBackground() { context in
            
            let sequence: VSequence = context.findOrCreateObject( ["remoteId" : String(self.sequenceID)] )
            for pollResult in pollResults where pollResult.sequenceID != nil {
                let uniqueElements = [
                    "answerId" : NSNumber(longLong: pollResult.answerID),
                    "sequenceId" : String(pollResult.sequenceID)
                ]
                let persistentResult: VPollResult = context.findOrCreateObject( uniqueElements )
                persistentResult.populate(fromSourceModel:pollResult)
                persistentResult.sequenceId = String(self.sequenceID)
                persistentResult.sequence = sequence
            }
            
            context.saveChanges()
            completion()
        }
    }
}
