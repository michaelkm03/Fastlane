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
    
    init(sequenceID: Int64, answerID: Int64) {
        self.request = PollVoteRequest(sequenceID: sequenceID, answerID: answerID)
    }
    
    override func main() {
        
        // Peform optimistic changes before the request is executed
        persistentStore.syncFromBackground() { context in
            guard let user = VUser.currentUser() else {
                fatalError( "User must be logged in." )
            }
            
            guard let sequence: VSequence = context.findObjects( [ "remoteId" : String(self.request.sequenceID)] ).first else {
                fatalError( "Cannot find sequence" )
            }
            
            let pollResult: VPollResult = context.createObject()
            pollResult.sequenceId = String(self.request.sequenceID)
            pollResult.answerId = NSNumber(longLong: self.request.answerID)
            pollResult.sequence = sequence
            pollResult.count = pollResult.count.integerValue + 1
            pollResult.user = user
            
            context.saveChanges()
        }
        
        // Then execute the request
        self.executeRequest( request )
    }
}