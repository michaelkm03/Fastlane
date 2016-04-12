//
//  ConversationOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 3/3/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

final class ConversationOperation: FetcherOperation, PaginatedOperation {
    
    let conversationID: Int?
    let userID: Int?
    let paginator: StandardPaginator
    
    var conversation: VConversation?
    
    /// For Objective-C
    convenience init(conversationID: NSNumber?, userID: NSNumber?) {
        self.init(conversationID: conversationID?.integerValue, userID: conversationID?.integerValue)
    }
    
    required init( conversationID: Int?, userID: Int?, paginator: StandardPaginator = StandardPaginator() ) {
        self.conversationID = conversationID
        self.userID = userID
        self.paginator = paginator
        super.init()
        
        if !localFetch {
            let request = ConversationRequest(
                conversationID: conversationID ?? 0,
                userID: userID,
                paginator: paginator
            )
            ConversationRemoteOperation(request: request).before(self).queue()
        }
    }
    
    required convenience init(operation: ConversationOperation, paginator: StandardPaginator) {
        self.init(conversationID: operation.conversationID, userID: operation.userID, paginator: paginator)
    }
    
    override func main() {
        self.results = fetchMessages()
        self.conversation = fetchConveration()
    }
    
    private func fetchMessages() -> [VMessage] {
        return persistentStore.mainContext.v_performBlockAndWait() { context in
            guard let messagesPredicate = self.messagesPredicate else {
                v_log("Unable to load messages without a converationID or userID.")
                assertionFailure()
                return []
            }
            
            let fetchRequest = NSFetchRequest(entityName: VMessage.v_entityName())
            fetchRequest.sortDescriptors = [ NSSortDescriptor(key: "displayOrder", ascending: false) ]
            fetchRequest.predicate = self.paginator.paginatorPredicate + messagesPredicate
            
            return context.v_executeFetchRequest( fetchRequest ) as [VMessage]
        }
    }
    
    private func fetchConveration() -> VConversation? {
        return persistentStore.mainContext.v_performBlockAndWait() { context in
            guard let conversationID = self.conversationID else {
                return nil
            }
            
            let fetchRequest = NSFetchRequest(entityName: VConversation.v_entityName())
            fetchRequest.predicate = NSPredicate(format: "remoteId == %i", conversationID)
            let conversations = context.v_executeFetchRequest( fetchRequest ) as [VConversation]
            
            assert(conversations.count == 1, "One conversation ID should only fetch one conversation")
            
            return conversations.first
        }
    }
    
    private lazy var messagesPredicate: NSPredicate? = {
        if let conversationID = self.conversationID where conversationID > 0 {
            return NSPredicate(format: "conversation.remoteId == %i", conversationID)
            
        } else if let userID = self.userID {
            return NSPredicate(format: "conversation.user.remoteId == %i", userID)
            
        } else {
            return nil
        }
    }()
}
