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
class PreloadUserInfoOperation: BackgroundOperation {
    private let dependencyManager: VDependencyManager

    init(dependencyManager: VDependencyManager) {
        self.dependencyManager = dependencyManager
        super.init()
    }
    
    private(set) var user: VUser?
    
    var persistentStore: PersistentStoreType = PersistentStoreSelector.defaultPersistentStore
    
    override func start() {
        super.start()
        beganExecuting()
        
        persistentStore.createBackgroundContext().v_performBlockAndWait() { [weak self] context in
            guard let strongSelf = self else {
                return
            }
            
            guard
                let userID = VCurrentUser.user(inManagedObjectContext: context)?.remoteId.integerValue,
                let apiPath = self?.dependencyManager.networkResources?.userFetchAPIPath,
                let infoOperation = UserInfoOperation(userID: userID, apiPath: apiPath)
            else {
                strongSelf.finishedExecuting()
                return
            }
            
            infoOperation.queue() { _ in
                strongSelf.user = infoOperation.user
                strongSelf.finishedExecuting()
            }
            
            FollowCountOperation(userID: userID).queue()

            VPushNotificationManager.sharedPushNotificationManager().sendTokenWithSuccessBlock(nil, failBlock: nil)
            
            UsersFollowedByUserOperation(userID: userID).queue()
            
            let request = HashtagSubscribedToListRequest(paginator: StandardPaginator(pageNumber: 1, itemsPerPage: 200))
            FollowedHashtagsRemoteOperation(request: request).queue()
        }
    }
}
