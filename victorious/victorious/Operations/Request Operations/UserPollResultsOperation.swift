//
//  UserPollResultsOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 11/18/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

class UserPollResultsOperation: RequestOperation<PollResultsRequest> {
    
    private let persistentStore = MainPersistentStore()
    private let userID: Int64
    
    init( userID: Int64) {
        self.userID = userID
        super.init(request: PollResultsRequest(userID: userID))
    }
    
    override func onComplete(response: PollResultsRequest.ResultType, completion:()->() ) {
        persistentStore.syncFromBackground() { context in
            let user: VUser = context.findObjects([ "remoteId" : Int(self.userID) ] ).first!
            for result in response {
                let pollResult = context.findOrCreateObject( [ "remoteId" : Int(result.answerID) ] ) as VPollResult
                pollResult.populate( fromSourceModel: result )
                user.pollResults.insert( pollResult )
            }
            context.saveChanges()
            completion()
        }
    }
}
