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
    
    let user: VictoriousIOSSDK.User
    
    var loadedConversation: VConversation?
    var loadedUser: VUser?
    
    required init(user: VictoriousIOSSDK.User) {
        self.user = user
    }
    
    override func start() {
        super.start()
        
        self.beganExecuting()
        
        persistentStore.mainContext.v_performBlockAndWait() { context in
            
            let user: VUser = context.v_findOrCreateObject( [ "remoteId" : self.user.userID ] )
            user.populate(fromSourceModel: self.user)
            self.loadedUser = user
            
            let filteredConversations = user.conversations.filter { ($0 as? VConversation)?.user?.remoteId == self.user.userID }
            if let conversation = filteredConversations.first as? VConversation {
                self.loadedConversation = conversation
                
                print( "\n\n------> Existing Conversation loaded for user: \(user.name)" )
            
            } else {
                let newConversation: VConversation = context.v_createObject()
                newConversation.user = user
                newConversation.isRead = true
                newConversation.postedAt = NSDate()
                self.loadedConversation = newConversation
                
                print( "\n\n------> New Conversation created for user: \(user.name)" )
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
            
            guard conversation.messages.count == 0 else {
                print( "\n\n------> Cannot delete Conversation for user: \(conversation.user.name).  There are messages already!" )
                self.finishedExecuting()
                return
            }
            
            print( "\n\n------> Empty Conversation deleted for user: \(conversation.user.name)" )
        
            context.deleteObject(conversation)
            context.v_save()
            
            self.finishedExecuting()
        }
    }
}
