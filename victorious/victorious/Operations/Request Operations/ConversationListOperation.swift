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
    private(set) var didResetResults: Bool = false
    
    required init( request: ConversationListRequest = ConversationListRequest()) {
        self.request = request
    }
    
    override func main() {
        executeRequest( request, onComplete: self.onComplete, onError: self.onError )
    }
    
    func onError( error: NSError, completion: ()->() ) {
        if error.code == RequestOperation.errorCodeNoNetworkConnection {
            self.results = fetchResults()
        }
        completion()
    }
    
    func onComplete( conversations: ConversationListRequest.ResultType, completion:()->() ) {
        
        persistentStore.backgroundContext.v_performBlock() { context in
            var displayOrder = (self.request.paginator.pageNumber - 1) * self.request.paginator.itemsPerPage
            
            var persistentConversations = [VConversation]()
            for conversation in conversations {
                let uniqueElements = [ "remoteId" : NSNumber( longLong: conversation.conversationID) ]
                let persistentConversation: VConversation = context.v_findOrCreateObject( uniqueElements )
                persistentConversation.populate( fromSourceModel: conversation )
                persistentConversation.displayOrder = displayOrder++
                persistentConversations.append( persistentConversation )
            }
            context.v_save()
            
            // Reload results from main queue
            self.results = self.fetchResults()
            completion()
        }
    }
    
    func fetchResults() -> [VConversation] {
        return persistentStore.mainContext.v_performBlockAndWait() { context in
            let fetchRequest = NSFetchRequest(entityName: VConversation.v_entityName())
            fetchRequest.sortDescriptors = [ NSSortDescriptor(key: "displayOrder", ascending: true) ]
            let predicate = NSPredicate(paginator: self.request.paginator)
            fetchRequest.predicate = predicate
            return context.v_executeFetchRequest( fetchRequest )
        }
    }
}
