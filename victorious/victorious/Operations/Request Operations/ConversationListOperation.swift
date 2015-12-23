//
//  ConversationListOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 11/11/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

final class ConversationListOperation: RequestOperation, PaginatedOperation {
    
    let request: ConversationListRequest
    private(set) var resultCount: Int?
    
    required init( request: ConversationListRequest ) {
        self.request = request
    }
    
    override convenience init() {
        self.init( request: ConversationListRequest() )
    }
    
    override func main() {
        executeRequest( request, onComplete: self.onComplete, onError: self.onError )
    }
    
    private func onError( error: NSError, completion:(()->()) ) {
        self.resultCount = 0
        completion()
    }
    
    private func onComplete( conversations: ConversationListRequest.ResultType, completion:()->() ) {
        self.resultCount = conversations.count
        
        persistentStore.backgroundContext.v_performBlock() { context in
            for conversation in conversations {
                let uniqueElements = [ "remoteId" : NSNumber( longLong: conversation.conversationID) ]
                let persistentConversation: VConversation = context.v_findOrCreateObject( uniqueElements )
                persistentConversation.populate( fromSourceModel: conversation )
            }
            context.v_save()
            completion()
        }
    }
}