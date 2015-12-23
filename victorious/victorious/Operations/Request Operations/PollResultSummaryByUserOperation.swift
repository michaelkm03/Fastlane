//
//  PollResultSummaryByUserOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 12/7/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

final class PollResultSummaryByUserOperation: RequestOperation, PaginatedOperation {
    
    let request: PollResultSummaryRequest
    
    var results: [AnyObject]?
    
    private let userID: Int64
    
    required init( request: PollResultSummaryRequest ) {
        self.userID = request.userID!
        self.request = request
    }
    
    convenience init( userID: Int64, pageNumber: Int = 1, itemsPerPage: Int = 15) {
        self.init( request: PollResultSummaryRequest(userID: userID) )
    }
    
    override func main() {
        executeRequest( request, onComplete: self.onComplete )
    }
    
    private func onError( error: NSError, completion:()->() ) {
        self.results = []
        completion()
    }
    
    private func onComplete( pollResults: PollResultSummaryRequest.ResultType, completion:()->() ) {
        
        persistentStore.backgroundContext.v_performBlock() { context in
            defer {
                completion()
            }
            
            // Update the user
            guard let user: VUser = context.v_findObjects( [ "remoteId" :  NSNumber(longLong: self.userID) ] ).first else {
                return
            }
            
            for pollResult in pollResults {
                var uniqueElements = [String : AnyObject]()
                if let answerID = pollResult.answerID {
                    uniqueElements[ "answerId" ] = NSNumber(longLong: answerID)
                }
                if let sequenceID = pollResult.sequenceID {
                    uniqueElements[ "sequenceId" ] = String(sequenceID)
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
