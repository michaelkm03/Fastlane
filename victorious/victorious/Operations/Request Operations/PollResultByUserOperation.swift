//
//  PollResultByUserOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 12/1/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

class PollResultByUserOperation: RequestOperation<PollResultByUserRequest> {
    
    private let persistentStore: PersistentStoreType = MainPersistentStore()
    private let userID: Int64
    
    init( userID: Int64 ) {
        self.userID = userID
        super.init( request: PollResultByUserRequest(userID: userID) )
    }
    
    override func onError(error: NSError, completion: () -> ()) {
        completion()
    }
    
    override func onComplete( response: PollResultByUserRequest.ResultType, completion:()->() ) {
        
        persistentStore.asyncFromBackground() { context in
            let pollResults: [VPollResult] = response.flatMap {
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
