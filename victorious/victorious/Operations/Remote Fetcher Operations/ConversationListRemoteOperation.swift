//
//  ConversationListRemoteOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 3/3/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

final class ConversationListRemoteOperation: RemoteFetcherOperation, PaginatedRequestOperation {
    
    let request: ConversationListRequest
    
    required init( request: ConversationListRequest = ConversationListRequest() ) {
        self.request = request
    }
    
    override func main() {
        requestExecutor.executeRequest( request, onComplete: onComplete, onError: nil )
    }
    
    func onComplete( results: ConversationListRequest.ResultType) {
        guard !results.isEmpty else {
            return
        }
        
        persistentStore.createBackgroundContext().v_performBlockAndWait() { context in
            var displayOrder = self.request.paginator.displayOrderCounterStart
            for result in results {
                let uniqueElements = [ "user.remoteId": result.otherUser.id ]
                let conversation: VConversation = context.v_findOrCreateObject( uniqueElements )
                conversation.populate( fromSourceModel: result )
                conversation.displayOrder = displayOrder
                displayOrder += 1
            }
            context.v_save()
        }
    }
}
