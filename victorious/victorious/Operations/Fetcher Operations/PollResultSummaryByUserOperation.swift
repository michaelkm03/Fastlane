//
//  PollResultSummaryByUserOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 12/7/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

final class PollResultSummaryByUserOperation: RemoteFetcherOperation, PaginatedRequestOperation {
    
    let request: PollResultSummaryRequest
    
    private let userID: Int
    
    required init( request: PollResultSummaryRequest ) {
        self.userID = request.userID!
        self.request = request
    }
    
    convenience init( userID: Int, pageNumber: Int = 1, itemsPerPage: Int = 15) {
        self.init( request: PollResultSummaryRequest(userID: userID) )
    }
    
    override func main() {
        requestExecutor.executeRequest( request, onComplete: onComplete, onError: nil )
    }
    
    private func onComplete( pollResults: PollResultSummaryRequest.ResultType) {
        
        persistentStore.createBackgroundContext().v_performBlockAndWait() { context in
            
            guard let user: VUser = context.v_findObjects( [ "remoteId" :  self.userID ] ).first else {
                return
            }
            
            for pollResult in pollResults {
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
                persistentResult.populate(fromSourceModel: pollResult)
                persistentResult.user = user
            }
            
            context.v_save()
        }
    }
}
