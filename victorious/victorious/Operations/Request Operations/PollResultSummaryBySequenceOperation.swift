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
    private(set) var results: [AnyObject]?
    private(set) var didResetResults: Bool = false
    
    private let sequenceID: String
    
    required init( request: PollResultSummaryRequest ) {
        self.sequenceID = request.sequenceID!
        self.request = request
    }
    
    convenience init( sequenceID: String ) {
        self.init( request: PollResultSummaryRequest(sequenceID: sequenceID) )
    }
    
    override func main() {
        requestExecutor.executeRequest( request, onComplete: self.onComplete, onError: self.onError )
    }
    
    private func onError( error: NSError, completion:(()->()) ) {
        self.results = []
        completion()
    }
    
    private func onComplete( pollResults: PollResultSummaryRequest.ResultType, completion:()->() ) {
        
        storedBackgroundContext = persistentStore.createBackgroundContext().v_performBlock() { context in
            
            let sequence: VSequence = context.v_findOrCreateObject( ["remoteId" : self.sequenceID] )
            for pollResult in pollResults where pollResult.sequenceID != nil {
                var uniqueElements = [String : AnyObject]()
                if let answerID = pollResult.answerID {
                    uniqueElements[ "answerId" ] = answerID
                }
                if let sequenceID = pollResult.sequenceID {
                    uniqueElements[ "sequenceId" ] = sequenceID
                }
                guard !uniqueElements.isEmpty else {
                    continue
                }
                let persistentResult: VPollResult = context.v_findOrCreateObject( uniqueElements )
                persistentResult.populate(fromSourceModel:pollResult)
                persistentResult.sequenceId = self.sequenceID
                persistentResult.sequence = sequence
            }
            
            context.v_save()
            completion()
        }
    }
}
