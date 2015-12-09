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
        
        persistentStore.asyncFromBackground() { context in
            
            // Parse users and their recent sequences in background context
            let suggestedUsers: [VSuggestedUser] = users.flatMap { sourceModel in
                let user: VUser = context.findOrCreateObject(["remoteId": NSNumber(longLong: sourceModel.user.userID)])
                user.populate(fromSourceModel: sourceModel.user)
                let recentSequences: [VSequence] = sourceModel.recentSequences.flatMap {
                    let sequence: VSequence = context.findOrCreateObject(["remoteId": String($0.sequenceID)])
                    sequence.populate(fromSourceModel: $0)
                    return sequence
                }
                return VSuggestedUser( user: user, recentSequences: recentSequences )
            }
            context.saveChanges()
            
            // Now reload on the main thread using the main context
            dispatch_async( dispatch_get_main_queue() ) {
                self.suggestedUsers = self.suggestedUsersFromMainContext( suggestedUsers )
                completion()
            }
        }
    }
    
    private func suggestedUsersFromMainContext( suggestedUsers: [VSuggestedUser] ) -> [VSuggestedUser] {
        var output = [VSuggestedUser]()
        persistentStore.sync() { context in
            for suggestedUser in suggestedUsers {
                guard let user: VUser = context.getObject( suggestedUser.user.identifier ) else {
                    fatalError( "Could not load user." )
                }
                let recentSequences: [VSequence] = suggestedUser.recentSequences.flatMap { context.getObject( $0.identifier ) }
                output.append( VSuggestedUser( user: user, recentSequences: recentSequences ) )
            }
        }
        return output
    }
}
