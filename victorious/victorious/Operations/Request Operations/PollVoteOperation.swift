//
//  PollVoteOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 12/14/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

final class PollVoteOperation: RemoteFetcherOperation, RequestOperation {
    
    let request: PollVoteRequest!
    
    init(sequenceID: String, answerID: Int) {
        self.request = PollVoteRequest(sequenceID: sequenceID, answerID: answerID)
    }
    
    override func main() {
        
        // Peform optimistic changes before the request is executed
        persistentStore.createBackgroundContext().v_performBlockAndWait() { context in
            guard let user = VCurrentUser.user(inManagedObjectContext: context) else {
                return
            }
            
            let pollResult: VPollResult = context.v_findOrCreateObject(["sequenceId": self.request.sequenceID, "answerId" : NSNumber(integer: self.request.answerID)])
            pollResult.count = pollResult.count.integerValue + 1
            pollResult.user = user
            
            context.v_save()
        }
        
        // Then execute the request
        requestExecutor.executeRequest( request, onComplete: nil, onError: nil )
    }
}