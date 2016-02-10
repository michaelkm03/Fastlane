//
//  PrunePersistentStoreOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 2/8/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

/// Deletes objects from the persistent store collected during regular use of the app.
/// This is useful when logging out and resetting a session.
///
/// TOOD: This operation is written while using an in-memory CoreData persistent store,
/// and freely deletes as much data as it wants without caring that the same objects
/// will be reloaded from the server.  In the future, we should expand on this and prune
/// according to necessities of a responsive and offline user experience.
class PrunePersistentStoreOperation: FetcherOperation {
    
    override func main() {
        
        // Perform on main context for high-prioerity, thread-blocking results:
        persistentStore.mainContext.v_performBlockAndWait() { context in
            
            context.v_deleteAllObjectsWithEntityName( VStreamItemPointer.v_entityName() )
            
            context.v_deleteAllObjectsWithEntityName( VComment.v_entityName() )
            context.v_deleteAllObjectsWithEntityName( VConversation.v_entityName() )
            context.v_deleteAllObjectsWithEntityName( VNotification.v_entityName() )
            context.v_deleteAllObjectsWithEntityName( VPollResult.v_entityName() )
            
            context.v_save()
        }
    }
}
