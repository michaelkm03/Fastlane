//
//  LoadUserConversationOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 1/13/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

class LoadUserConversationOperation: Operation {
    
    var persistentStore: PersistentStoreType = PersistentStoreSelector.defaultPersistentStore
    
    let sourceUser: VictoriousIOSSDK.User?
    let userID: Int
    
    var loadedConversation: VConversation?
    var loadedUser: VUser?
    
    required init(sourceUser: VictoriousIOSSDK.User) {
        self.userID = sourceUser.userID
        self.sourceUser = sourceUser
    }
    
    required init(userID: Int) {
        self.userID = userID
        self.sourceUser = nil
    }
    
    override func start() {
        super.start()
        
        self.beganExecuting()
        
        persistentStore.mainContext.v_performBlockAndWait() { context in
            
            let user: VUser = context.v_findOrCreateObject( [ "remoteId" : self.userID ] )
            if let sourceUser = self.sourceUser {
                user.populate(fromSourceModel: sourceUser)
            }
            self.loadedUser = user
            
            let filteredConversations = user.conversations.filter { ($0 as? VConversation)?.user?.remoteId == self.userID }
            if let conversation = filteredConversations.first as? VConversation {
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
        
        self.finishedExecuting()
    }
}

/// Deletes the provided conversation if there are no messages
class DeleteUnusedLocalConversationOperation: Operation {
    
    var persistentStore: PersistentStoreType = PersistentStoreSelector.defaultPersistentStore
    
    private let conversationID: Int
    
    required init(conversationID: Int) {
        self.conversationID = conversationID
    }
    
    override func start() {
        super.start()
        
        self.beganExecuting()
        
        persistentStore.createBackgroundContext().v_performBlockAndWait() { context in
            
            guard let conversation: VConversation = context.v_findObjects( [ "remoteId" : self.conversationID ] ).first else {
                self.finishedExecuting()
                return
            }
            
            guard let messages = conversation.messages where messages.count == 0 else {
                self.finishedExecuting()
                return
            }
        
            context.deleteObject(conversation)
            context.v_save()
            self.persistentStore.mainContext.v_performBlockAndWait() { context in
                context.v_save()
            }
            
            self.finishedExecuting()
        }
    }
}
