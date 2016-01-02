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
    
    private(set) var suggestedUsers: [VSuggestedUser] = []
    
    override func main() {
        executeRequest( self.request, onComplete: self.onComplete )
    }
    
    private func onComplete( users: [SuggestedUser], completion:()->() ) {
        
        persistentStore.backgroundContext.v_performBlock() { context in
            
            // Parse users and their recent sequences in background context
            let suggestedUsers: [VSuggestedUser] = users.flatMap { sourceModel in
                let user: VUser = context.v_findOrCreateObject(["remoteId": NSNumber(longLong: sourceModel.user.userID)])
                user.populate(fromSourceModel: sourceModel.user)
                let recentSequences: [VSequence] = sourceModel.recentSequences.flatMap {
                    let sequence: VSequence = context.v_findOrCreateObject(["remoteId": String($0.sequenceID)])
                    sequence.populate(fromSourceModel: $0)
                    return sequence
                }
                return VSuggestedUser( user: user, recentSequences: recentSequences )
            }
            context.v_save()
            
            // Now reload on the main thread using the main context
            dispatch_async( dispatch_get_main_queue() ) {
                self.suggestedUsers = self.suggestedUsersFromMainContext( suggestedUsers )
                completion()
            }
        }
    }
    
    private func suggestedUsersFromMainContext( suggestedUsers: [VSuggestedUser] ) -> [VSuggestedUser] {
        var output = [VSuggestedUser]()
        persistentStore.mainContext.v_performBlockAndWait() { context in
            for suggestedUser in suggestedUsers {
                guard let user = context.objectWithID( suggestedUser.user.objectID ) as? VUser else {
                    fatalError( "Could not load user." )
                }
                let recentSequences: [VSequence] = suggestedUser.recentSequences.flatMap {
                    context.objectWithID( $0.objectID ) as? VSequence
                }
                output.append( VSuggestedUser( user: user, recentSequences: recentSequences ) )
            }
        }
        return output
    }
}
