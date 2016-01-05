//
//  PollVoteOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 12/14/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

final class PollVoteOperation: RequestOperation {
    
    var request: PollVoteRequest
    
    init(sequenceID: String, answerID: Int64) {
        self.request = PollVoteRequest(sequenceID: sequenceID, answerID: answerID)
    }
    
    override func main() {
        
        // Peform optimistic changes before the request is executed
        persistentStore.backgroundContext.v_performBlockAndWait() { context in
            guard let user = VCurrentUser.user(),
                let sequence: VSequence = context.v_findObjects( [ "remoteId" : String(self.request.sequenceID)] ).first else {
                    return
            }
            
            let pollResult: VPollResult = context.v_createObject()
            pollResult.sequenceId = String(self.request.sequenceID)
            pollResult.answerId = NSNumber(longLong: self.request.answerID)
            pollResult.sequence = sequence
            pollResult.count = pollResult.count.integerValue + 1
            pollResult.user = user
            
            context.v_save()
        }
        
        // Then execute the request
        requestExecutor.executeRequest( request, onComplete: nil, onError: nil )
    }
}