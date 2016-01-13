//
//  SuggestedUsersOperation.swift
//  victorious
//
//  Created by Tian Lan on 11/23/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

class SuggestedUsersOperation: RequestOperation {
    
    let request = SuggestedUsersRequest()
    var suggestedUsers: [VSuggestedUser]?
    
    override func main() {
        requestExecutor.executeRequest( request, onComplete: onComplete, onError: nil )
    }
    
    func onComplete( users: SuggestedUsersRequest.ResultType, completion:()->() ) {
        
        storedBackgroundContext = persistentStore.createBackgroundContext().v_performBlock() { context in
            
            // Parse users and their recent sequences in background context
            let suggestedUsers: [VSuggestedUser] = users.flatMap { sourceModel in
                let user: VUser = context.v_findOrCreateObject(["remoteId": sourceModel.user.userID])
                user.populate(fromSourceModel: sourceModel.user)
                let recentSequences: [VSequence] = sourceModel.recentSequences.flatMap {
                    let sequence: VSequence = context.v_findOrCreateObject(["remoteId": $0.sequenceID])
                    sequence.populate(fromSourceModel: $0)
                    return sequence
                }
                return VSuggestedUser( user: user, recentSequences: recentSequences )
            }
            context.v_save()
            
            self.results = self.fetchResults( suggestedUsers )
            completion()
        }
    }
    
    func fetchResults( suggestedUsers: [VSuggestedUser] ) -> [VSuggestedUser] {
        return persistentStore.mainContext.v_performBlockAndWait() { context in
            var output = [VSuggestedUser]()
            for suggestedUser in suggestedUsers {
                guard let user = context.objectWithID( suggestedUser.user.objectID ) as? VUser else {
                    fatalError( "Could not load user." )
                }
                let recentSequences: [VSequence] = suggestedUser.recentSequences.flatMap {
                    context.objectWithID( $0.objectID ) as? VSequence
                }
                output.append( VSuggestedUser( user: user, recentSequences: recentSequences ) )
            }
            return output
        }
    }
}
