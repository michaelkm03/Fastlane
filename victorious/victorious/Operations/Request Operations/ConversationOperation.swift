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
            let request = ConversationRequest(conversationID: conversationID ?? 0, userID: userID, paginator: paginator)
            ConversationRemoteOperation(request: request).before(self).queue()
        }
    }
    
    required convenience init(operation: ConversationOperation, paginator: StandardPaginator) {
        self.init(conversationID: operation.conversationID, userID: operation.userID, paginator: paginator)
    }
    
    override func main() {
        persistentStore.mainContext.v_performBlockAndWait() { context in
            let fetchRequest = NSFetchRequest(entityName: VConversation.v_entityName())
            fetchRequest.predicate = self.conversationPredicate
            guard let conversation = context.v_executeFetchRequest( fetchRequest ).first as? VConversation else {
                VLog("Unable to load conversation.")
                assertionFailure()
                return
            }
            
            let predicate = self.paginator.paginatorPredicate
            guard let messages = conversation.messages?.filteredOrderedSetUsingPredicate(predicate) else {
                self.results = []
                return
            }
            let sortDescriptor = NSSortDescriptor(key: "displayOrder", ascending: false)
            self.results = messages.sortedArrayUsingDescriptors( [sortDescriptor] )
        }
    }
    
    private var conversationPredicate: NSPredicate? {
        if let conversationID = self.conversationID where conversationID > 0 {
            return NSPredicate(format: "remoteId == %i", conversationID)
            
        } else if let userID = self.userID {
            return NSPredicate(format: "user.remoteId == %i", userID)
            
        } else {
            return nil
        }
    }
}
