//
//  PollResultsOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 12/1/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

class PollResultSummaryBySequenceOperation: RequestOperation<PollResultSummaryRequest> {
    
    private let persistentStore: PersistentStoreType = MainPersistentStore()
    private let sequenceID: Int64?
    
    init( sequenceID: Int64 ) {
        self.sequenceID = sequenceID
        super.init( request: PollResultSummaryRequest(sequenceID: sequenceID) )
    }
    
    override func onComplete( response: PollResultSummaryRequest.ResultType, completion:()->() ) {
        
        persistentStore.asyncFromBackground() { context in
            
            let sequence: VSequence = context.findOrCreateObject( ["remoteId" : String(self.sequenceID)] )
            for pollResult in response where pollResult.sequenceID != nil {
                let uniqueElements = [
                    "answerId" : NSNumber(longLong: pollResult.answerID),
                    "sequenceId" : String(pollResult.sequenceID)
                ]
                let persistentResult: VPollResult = context.findOrCreateObject( uniqueElements )
                persistentResult.populate(fromSourceModel:pollResult)
                persistentResult.sequenceId = String(self.sequenceID)
                persistentResult.sequence = sequence
            }
            
            //context.saveChanges()
            completion()
        }
    }
}

class PollResultSummaryByUserOperation: RequestOperation<PollResultSummaryRequest> {
    
    private let persistentStore: PersistentStoreType = MainPersistentStore()
    private let userID: Int64?
    
    init( userID: Int64 ) {
        self.userID = userID
        super.init( request: PollResultSummaryRequest(userID: userID) )
    }
    
    override func onComplete( response: PollResultSummaryRequest.ResultType, completion:()->() ) {
        
        persistentStore.asyncFromBackground() { context in
            defer {  completion() }
            
            // Update the user
            guard let userID = self.userID,
                let user: VUser = context.findObjects( [ "remoteId" :  NSNumber(longLong: userID) ] ).first else {
                    return
            }
            
            for pollResult in response {
                let uniqueElements = [
                    "answerId" : NSNumber(longLong: pollResult.answerID),
                    "sequenceId" : String(pollResult.sequenceID)
                ]
                let persistentResult: VPollResult = context.findOrCreateObject( uniqueElements )
                persistentResult.populate(fromSourceModel: pollResult)
                persistentResult.user = user
            }
            
            //context.saveChanges()
        }
    }
}
