//
//  PollResultSummaryByUserOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 12/7/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

final class PollResultSummaryByUserOperation: RequestOperation, PageableOperationType {
    
    var currentRequest: PollResultSummaryRequest
    private let userID: Int64
    
    required init( request: PollResultSummaryRequest ) {
        self.userID = request.userID!
        self.currentRequest = request
    }
    
    convenience init( userID: Int64, pageNumber: Int = 1, itemsPerPage: Int = 15) {
        self.init( request: PollResultSummaryRequest(userID: userID) )
    }
    
    override func main() {
        executeRequest( currentRequest, onComplete: self.onComplete )
    }
    
    private func onComplete( pollResults: PollResultSummaryRequest.ResultType, completion:()->() ) {
        
        persistentStore.asyncFromBackground() { context in
            defer {  completion() }
            
            // Update the user
            guard let user: VUser = context.findObjects( [ "remoteId" :  NSNumber(longLong: self.userID) ] ).first else {
                return
            }
            
            for pollResult in pollResults {
                let uniqueElements = [
                    "answerId" : NSNumber(longLong: pollResult.answerID),
                    "sequenceId" : String(pollResult.sequenceID)
                ]
                let persistentResult: VPollResult = context.findOrCreateObject( uniqueElements )
                persistentResult.populate(fromSourceModel: pollResult)
                persistentResult.user = user
            }
            
            context.saveChanges()
        }
    }
}