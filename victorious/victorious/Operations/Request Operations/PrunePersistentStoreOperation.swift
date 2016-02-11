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
/// TODO: This operation was written while using an in-memory CoreData persistent store,
/// and freely deletes as much data as it wants without caring that the same objects
/// will be reloaded from the server.  In the future, we should expand on this and prune
/// according to necessities of a responsive and offline user experience.
class PrunePersistentStoreOperation: FetcherOperation {
    
    override func main() {
        
        // Perform on main context for high-priority, thread-blocking results:
        persistentStore.mainContext.v_performBlockAndWait() { context in
            
            // Delete stream pointers to remove all stream items from all streams.
            // This wipes the slate clean for a new user to come along and re-load
            // streams specific to their them.
            
            context.v_deleteAllObjectsWithEntityName( VStreamItemPointer.v_entityName() )
            
            // Delete any and all other objects that only exist for a current user.
            // This prevents old conversations or notificaitons from appearing after logout.
            
            context.v_deleteAllObjectsWithEntityName( VConversation.v_entityName() )
            context.v_deleteAllObjectsWithEntityName( VNotification.v_entityName() )
            context.v_deleteAllObjectsWithEntityName( VPollResult.v_entityName() )
            
            context.v_save()
        }
    }
}
