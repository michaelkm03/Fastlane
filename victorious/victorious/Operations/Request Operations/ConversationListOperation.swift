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
    
    required init( request: ConversationListRequest = ConversationListRequest() ) {
        self.request = request
    }
    
    override func main() {
        requestExecutor.executeRequest( request, onComplete: onComplete, onError: nil )
    }
    
    func onComplete( results: ConversationListRequest.ResultType, completion:()->() ) {
        guard !results.isEmpty else {
            completion()
            return
        }
        
        // Filter flagged comments here so that they never even make it into the persistent store
        let flaggedIDs: [Int] = VFlaggedContent().flaggedContentIdsWithType(.Conversation).flatMap { Int($0) }
        let unflaggedResults = results.filter { flaggedIDs.contains($0.conversationID) == false }
        
        storedBackgroundContext = persistentStore.createBackgroundContext().v_performBlock() { context in
            var displayOrder = self.request.paginator.start
            for result in unflaggedResults {
                let uniqueElements = [ "remoteId" : result.conversationID ]
                let conversation: VConversation = context.v_findOrCreateObject( uniqueElements )
                conversation.populate( fromSourceModel: result )
                conversation.displayOrder = displayOrder++
            }
            context.v_save()
            completion()
        }
    }
    
    // MARK: - PaginatedOperation
    
    internal(set) var results: [AnyObject]?
    
    func clearResults() {
        persistentStore.mainContext.v_performBlockAndWait() { context in
            let existing: [VConversation] = context.v_findAllObjects()
            for object in existing {
                context.deleteObject( object )
            }
            context.v_save()
        }
    }
    
    func fetchResults() -> [AnyObject] {
        return persistentStore.mainContext.v_performBlockAndWait() { context in
            let fetchRequest = NSFetchRequest(entityName: VConversation.v_entityName())
            fetchRequest.sortDescriptors = [ NSSortDescriptor(key: "displayOrder", ascending: true) ]
            return context.v_executeFetchRequest( fetchRequest ) as [VConversation]
        }
    }
}
