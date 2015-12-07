//
//  PollResultByUserOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 12/1/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

class PollResultByUserOperation: RequestOperation {
    
    private let userID: Int64
    
    var request: PollResultByUserRequest
    
    init( userID: Int64 ) {
        self.userID = userID
        self.request = PollResultByUserRequest(userID: userID)
    }
    
    override func main() {
        self.executeRequest( request, onComplete: self.onComplete )
    }
    
    private func onComplete( polls: PollResultByUserRequest.ResultType, completion:()->() ) {
        
        persistentStore.asyncFromBackground() { context in
            let pollResults: [VPollResult] = polls.flatMap {
                let uniqueElements = [
                    "answerId" : NSNumber(longLong: $0.answerID),
                    "sequenceId" : String($0.sequenceID)
                ]
                let persistentResult: VPollResult = context.findOrCreateObject( uniqueElements )
                persistentResult.populate(fromSourceModel: $0)
                return persistentResult
            }
            guard let user: VUser = context.findObjects( [ "remoteId" :  NSNumber(longLong: self.userID) ] ).first else {
                fatalError( "Could not load user with provided user ID" )
            }
            user.addObjects( pollResults, to: "pollResults" )
            context.saveChanges()
            completion()
        }
    }
}
