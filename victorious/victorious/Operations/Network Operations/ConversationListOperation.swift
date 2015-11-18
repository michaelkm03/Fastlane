//
//  ConversationListOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 11/11/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

class ConversationListOperation: RequestOperation<ConversationListRequest> {
    
    init() {
        super.init( request: ConversationListRequest() )
    }
    
    override func onResponse( result: (results: [Conversation], nextPage: ConversationListRequest?, previousPage: ConversationListRequest?) ) {
        
        let persistentStore = PersistentStore()
        for conversation in result.results {
            let uniqueElements = [ "remoteId" : Int(conversation.conversationID) ]
            let persistentConversation: VConversation = persistentStore.backgroundContext.findOrCreateObject( uniqueElements )
            persistentConversation.populate( fromSourceModel: conversation )
        }
        persistentStore.backgroundContext.saveChanges()
    }
}