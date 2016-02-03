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
        
        // Filter flagged conversations here so that they never even make it into the persistent store
        let flaggedIDs: [Int] = VFlaggedContent().flaggedContentIdsWithType(.Conversation).flatMap { Int($0) }
        let unflaggedResults = results.filter { flaggedIDs.contains($0.conversationID) == false }
        
        storedBackgroundContext = persistentStore.createBackgroundContext().v_performBlock() { context in
            var displayOrder = self.request.paginator.displayOrderCounterStart
            for result in unflaggedResults {
                let uniqueElements = [ "user.remoteId" : result.otherUser.userID ]
                let conversation: VConversation = context.v_findOrCreateObject( uniqueElements )
                conversation.populate( fromSourceModel: result )
                conversation.displayOrder = displayOrder++
            }
            context.v_save()
            dispatch_async( dispatch_get_main_queue() ) {
                self.results = self.fetchResults()
                completion()
            }
        }
    }
    
    func fetchResults() -> [AnyObject] {
        return persistentStore.mainContext.v_performBlockAndWait() { context in
            let fetchRequest = NSFetchRequest(entityName: VConversation.v_entityName())
            fetchRequest.sortDescriptors = [ NSSortDescriptor(key: Victorious.Keys.displayOrder.rawValue, ascending: true) ]
            fetchRequest.predicate = self.request.paginator.paginatorPredicate
            return context.v_executeFetchRequest( fetchRequest ) as [VConversation]
        }
    }
}

class FetchConverationListOperation: FetcherOperation {
    
    let userID: Int
    let paginator: NumericPaginator
    
    init( userID: Int, paginator: NumericPaginator = StandardPaginator() ) {
        self.userID = userID
        self.paginator = paginator
    }
    
    override func main() {
        self.results = persistentStore.mainContext.v_performBlockAndWait() { context in
            let fetchRequest = NSFetchRequest(entityName: VConversation.v_entityName())
            fetchRequest.sortDescriptors = [ NSSortDescriptor(key: Victorious.Keys.displayOrder.rawValue, ascending: true) ]
            let hasMessagesPredicate = NSPredicate(format: "messages.@count > 0")
            fetchRequest.predicate = self.paginator.paginatorPredicate + hasMessagesPredicate
            let results = context.v_executeFetchRequest( fetchRequest ) as [VConversation]
            return results
        }
    }
}
