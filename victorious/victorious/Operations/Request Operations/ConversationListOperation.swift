//
//  ConversationListOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 11/11/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

final class ConversationListOperation: RemoteFetcherOperation, PaginatedRequestOperation {
    
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
        
        persistentStore.createBackgroundContext().v_performBlockAndWait() { context in
            
            var displayOrder = self.request.paginator.displayOrderCounterStart
            for result in results {
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
            let hasRemoteIdPredicate = NSPredicate(format: "remoteId != nil")
            fetchRequest.predicate = self.request.paginator.paginatorPredicate + hasRemoteIdPredicate
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
