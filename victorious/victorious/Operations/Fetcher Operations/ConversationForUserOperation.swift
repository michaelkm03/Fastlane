//
//  ConversationForUserOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 1/13/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

class ConversationForUserOperation: FetcherOperation {
    
    let sourceUser: VictoriousIOSSDK.User?
    let userID: Int
    
    var loadedConversation: VConversation?
    var loadedUser: VUser?
    
    required init(sourceUser: VictoriousIOSSDK.User) {
        self.userID = sourceUser.id
        self.sourceUser = sourceUser
    }
    
    required init(userID: Int) {
        self.userID = userID
        self.sourceUser = nil
    }
    
    override func main() {
        persistentStore.mainContext.v_performBlockAndWait() { context in
            
            let user: VUser = context.v_findOrCreateObject( [ "remoteId" : self.userID ] )
            if let sourceUser = self.sourceUser {
                user.populate(fromSourceModel: sourceUser)
            }
            self.loadedUser = user
            
            let filteredConversations = user.conversations?.filter { ($0 as? VConversation)?.user?.remoteId == self.userID }
            if let conversation = filteredConversations?.first as? VConversation {
                self.loadedConversation = conversation
            
            } else {
                let newConversation: VConversation = context.v_createObject()
                newConversation.user = user
                newConversation.isRead = true
                newConversation.postedAt = NSDate()
                self.loadedConversation = newConversation
            }
            
            self.loadedConversation?.user = self.loadedUser
            context.v_save()
        }
    }
}
