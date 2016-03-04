//
//  ConversationListOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 11/11/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

final class ConversationListOperation: FetcherOperation, PaginatedOperation {
    
    let paginator: StandardPaginator
    
    required init(paginator: StandardPaginator = StandardPaginator()) {
        self.paginator = paginator
        super.init()
        
        if !localFetch {
            let request = ConversationListRequest(paginator: paginator)
            ConversationListRemoteOperation(request: request).before(self).queue()
        }
    }
    
    required convenience init(operation: ConversationListOperation, paginator: StandardPaginator) {
        self.init(paginator: paginator)
    }
    
    override func main() {
        persistentStore.mainContext.v_performBlockAndWait() { context in
            let fetchRequest = NSFetchRequest(entityName: VConversation.v_entityName())
            fetchRequest.sortDescriptors = [ NSSortDescriptor(key: Victorious.Keys.displayOrder.rawValue, ascending: true) ]
            let hasRemoteIdPredicate = NSPredicate(format: "remoteId != nil")
            //let hasMessagesPredicate = NSPredicate(format: "messages.@count > 0")
            fetchRequest.predicate = self.paginator.paginatorPredicate + hasRemoteIdPredicate
            self.results = context.v_executeFetchRequest( fetchRequest ) as [VConversation]
        }
    }
}
