//
//  PreloadUserInfoOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 1/20/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

/// Executes several sub operations that pre-load user info including conversations, poll responses,
/// profile data, profile stream, etc.  Intended to be called just after login.
class PreloadUserInfoOperation: Operation {
    
    var persistentStore: PersistentStoreType = PersistentStoreSelector.defaultPersistentStore
    
    override func start() {
        super.start()
        beganExecuting()
        
        persistentStore.createBackgroundContext().v_performBlockAndWait() { context in
            guard let currentUser = VCurrentUser.user(inManagedObjectContext: context) else {
                return
            }
            
            let userID = currentUser.remoteId.integerValue
            let apiPath = VStreamItem.apiPathForStreamWithUserID(currentUser.remoteId)
            let paginator = StreamPaginator(apiPath: apiPath, sequenceID: nil, pageNumber: 1, itemsPerPage: 45)
            if let request = StreamRequest(apiPath: apiPath, sequenceID: nil, paginator: paginator) {
                StreamOperation(request: request).queue()
            }
            
            UserInfoOperation(userID: userID).queue()
            
            PollResultSummaryByUserOperation(userID: userID).queue()
            
            ConversationListOperation().queue()
            
            FollowCountOperation(userID: currentUser.remoteId.integerValue).queue()

            VPushNotificationManager.sharedPushNotificationManager().sendTokenWithSuccessBlock(nil, failBlock: nil)
            
            UsersFollowedByUserOperation(userID: currentUser.remoteId.integerValue).queue()
            
            let request = HashtagSubscribedToListRequest(paginator: StandardPaginator(pageNumber: 1, itemsPerPage: 200))
            FollowedHashtagsOperation(request: request).queue()
        }
        
        finishedExecuting()
    }
}
