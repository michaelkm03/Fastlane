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
        persistentStore.mainContext.v_performBlockAndWait() { context in
            guard let messagesPredicate = self.messagesPredicate else {
                VLog("Unable to load messages without a converationID or userID.")
                assertionFailure()
                return
            }
            
            let fetchRequest = NSFetchRequest(entityName: VMessage.v_entityName())
            fetchRequest.sortDescriptors = [ NSSortDescriptor(key: "displayOrder", ascending: false) ]
            fetchRequest.predicate = self.paginator.paginatorPredicate + messagesPredicate
            let results = context.v_executeFetchRequest( fetchRequest ) as [VMessage]
            self.results = results
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
