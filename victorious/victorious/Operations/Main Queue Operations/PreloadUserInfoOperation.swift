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
final class PreloadUserInfoOperation: AsyncOperation<VUser> {
    private let dependencyManager: VDependencyManager

    init(dependencyManager: VDependencyManager) {
        self.dependencyManager = dependencyManager
        super.init()
    }
    
    private let persistentStore: PersistentStoreType = PersistentStoreSelector.defaultPersistentStore
    
    override var executionQueue: Queue {
        return .background
    }
    
    override func execute(finish: (result: OperationResult<VUser>) -> Void) {
        persistentStore.createBackgroundContext().v_performBlockAndWait() { [weak self] context in
            guard
                let userID = VCurrentUser.user(inManagedObjectContext: context)?.remoteId.integerValue,
                let apiPath = self?.dependencyManager.networkResources?.userFetchAPIPath,
                let infoOperation = UserInfoOperation(userID: userID, apiPath: apiPath)
            else {
                finish(result: .failure(NSError(domain: "PreloadUserInfoOperation", code: -1, userInfo: nil)))
                return
            }
            
            infoOperation.queue() { _ in
                guard let user = infoOperation.user else {
                    finish(result: .failure(NSError(domain: "PreloadUserInfoOperation", code: -1, userInfo: nil)))
                    return
                }
                finish(result: .success(user))
            }
        }
    }
}
