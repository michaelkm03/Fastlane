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
    private(set) var results: [AnyObject]?
    
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
        self.results = []
        completion()
    }
    
    private func onComplete( conversations: ConversationListRequest.ResultType, completion:()->() ) {
        
        persistentStore.backgroundContext.v_performBlock() { context in
            var persistentConversations = [VConversation]()
            for conversation in conversations {
                let uniqueElements = [ "remoteId" : NSNumber( longLong: conversation.conversationID) ]
                let persistentConversation: VConversation = context.v_findOrCreateObject( uniqueElements )
                persistentConversation.populate( fromSourceModel: conversation )
                persistentConversations.append( persistentConversation )
            }
            context.v_save()
            
            let objectIDs = persistentConversations.map { $0.objectID }
            self.persistentStore.mainContext.v_performBlock() { context in
                self.results = objectIDs.flatMap { context.objectWithID($0) as? VConversation }
                completion()
            }
        }
    }
}