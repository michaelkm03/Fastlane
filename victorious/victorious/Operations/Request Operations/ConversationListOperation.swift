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
    
    private let persistentStore: PersistentStoreType = MainPersistentStore()
    
    init() {
        super.init( request: ConversationListRequest() )
    }
    
    override func onComplete( result: ConversationListRequest.ResultType, completion: ()->() ) {
        
        persistentStore.asyncFromBackground() { context in
            for conversation in result.results {
                let uniqueElements = [ "remoteId" : Int(conversation.conversationID) ]
                let persistentConversation: VConversation = context.findOrCreateObject( uniqueElements )
                persistentConversation.populate( fromSourceModel: conversation )
            }
            context.saveChanges()
            completion()
        }
    }
}