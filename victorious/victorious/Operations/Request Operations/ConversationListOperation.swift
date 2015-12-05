//
//  ConversationListOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 11/11/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

final class ConversationListOperation: RequestOperation, PageableOperationType {
    
    var currentRequest: ConversationListRequest
    
    required init( request: ConversationListRequest ) {
        self.currentRequest = request
    }
    
    override convenience init() {
        self.init( request: ConversationListRequest() )
    }
    
    override func main() {
        executeRequest( currentRequest, onComplete: self.onComplete )
    }
    
    private func onComplete( conversations: ConversationListRequest.ResultType, completion:()->() ) {
        self.resultCount = conversations.count
        
        persistentStore.asyncFromBackground() { context in
            for conversation in conversations {
                let uniqueElements = [ "remoteId" : NSNumber( longLong: conversation.conversationID) ]
                let persistentConversation: VConversation = context.findOrCreateObject( uniqueElements )
                persistentConversation.populate( fromSourceModel: conversation )
            }
            context.saveChanges()
            completion()
        }
    }
}