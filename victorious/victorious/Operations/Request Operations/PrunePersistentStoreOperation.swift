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
/// This operation was written while using an in-memory CoreData persistent store,
/// and freely deletes as much data as it wants without caring that the same objects
/// will be reloaded from the server.  In the future, we should expand on this and prune
/// according to necessities of a responsive and offline user experience.
class NewSessionPrunePersistentStoreOperation: FetcherOperation {
    
    override func main() {
        
        // Perform on main context for high-priority, thread-blocking results:
        persistentStore.createBackgroundContext().v_performBlockAndWait() { context in
            
            // Delete streams when we want to clear the persistent store for a new session
            
            context.v_deleteAllObjectsWithEntityName( VStream.v_entityName() )
            
            context.v_saveAndBubbleToParentContext()
        }
    }
}

class LogoutPrunePersistentStoreOperation: FetcherOperation {
    
    override func main() {
        
        // Perform on main context for high-priority, thread-blocking results:
    persistentStore.createBackgroundContext().v_performBlockAndWait() { context in
            
            let fetchRequest = NSFetchRequest(entityName: VStreamItemPointer.v_entityName())
            let userPostPredicate = NSPredicate(format: "streamParent.streamId == %@", "feed:following")
            let followingStreamPredicate = NSPredicate(format: "streamParent.streamId == %@", "user_posts")
            fetchRequest.predicate = userPostPredicate + followingStreamPredicate
            
            context.v_deleteObjects(fetchRequest)
            
            // Delete all objects that only exist for a current user.
            // This prevents old conversations or notificaitons from appearing after logout.
            
            context.v_deleteAllObjectsWithEntityName( VConversation.v_entityName() )
            context.v_deleteAllObjectsWithEntityName( VNotification.v_entityName() )
            context.v_deleteAllObjectsWithEntityName( VPollResult.v_entityName() )
            
            context.v_saveAndBubbleToParentContext()
        }
    }
}
