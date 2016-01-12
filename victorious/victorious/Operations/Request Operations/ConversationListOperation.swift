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
    
    required init( request: ConversationListRequest = ConversationListRequest()) {
        self.request = request
        super.init()
    }
    
    override func main() {
        requestExecutor.executeRequest( request, onComplete: self.onComplete, onError: nil )
    }
    
    func onComplete( conversations: ConversationListRequest.ResultType, completion:()->() ) {
        persistentStore.backgroundContext.v_performBlock() { context in
            
            var displayOrder = self.paginatedRequestExecutor.startingDisplayOrder
            var persistentConversations = [VConversation]()
            for conversation in conversations {
                let uniqueElements = [ "remoteId" : conversation.conversationID ]
                let persistentConversation: VConversation = context.v_findOrCreateObject( uniqueElements )
                persistentConversation.populate( fromSourceModel: conversation )
                persistentConversation.displayOrder = displayOrder++
                persistentConversations.append( persistentConversation )
            }
            context.v_save()
            completion()
        }
    }
    
    override func fetchResults() -> [AnyObject] {
        return persistentStore.mainContext.v_performBlockAndWait() { context in
            let fetchRequest = NSFetchRequest(entityName: VConversation.v_entityName())
            fetchRequest.sortDescriptors = [ NSSortDescriptor(key: "displayOrder", ascending: true) ]
            return context.v_executeFetchRequest( fetchRequest )
        }
    }
    
    override func clearResults() {
        persistentStore.mainContext.v_performBlockAndWait() { context in
            let existingComments: [VConversation] = context.v_findAllObjects()
            for comment in existingComments {
                context.deleteObject( comment )
            }
            context.v_save()
        }
    }
}
