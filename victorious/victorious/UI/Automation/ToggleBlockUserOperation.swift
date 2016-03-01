//
//  ToggleBlockUserOperation.swift
//  victorious
//
//  Created by Sharif Ahmed on 2/29/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

class ToggleBlockUserOperation: FetcherOperation {
    
    private let userID: Int
    private let dependencyManager: VDependencyManager?
    private let originViewController: UIViewController?
    
    init( originViewController: UIViewController, dependencyManager: VDependencyManager, userID: Int ) {
        self.userID = userID
        self.dependencyManager = dependencyManager
        self.originViewController = originViewController
    }
    
    init(userID: Int ) {
        self.userID = userID
        self.dependencyManager = nil
        self.originViewController = nil
    }
    
    override func main() {
        guard didConfirmActionFromDependencies else {
            self.cancel()
            return
        }
        
        let fetchedUser: VUser? = persistentStore.mainContext.v_performBlockAndWait() { context in
            return context.v_findObjects(["remoteId" : self.userID]).first
        }
        guard let user = fetchedUser else {
            assertionFailure("Unable to load user with ID: \(self.userID)")
            return
        }
        
        let isBlocked = user.isBlockedByMainUser.boolValue
        
        let nextOperation: FetcherOperation
        if isBlocked {
            nextOperation = UnblockUserOperation(userID: userID)
        } else {
            nextOperation = BlockUserOperation(userID: userID)
        }
        
        if let originViewController = originViewController, let dependencyManager = dependencyManager {
            
            let confirmation = ShowBlockUserConfirmationAlertOperation(
                originViewController: originViewController,
                dependencyManager: dependencyManager,
                shouldUnblockUser: isBlocked
            )
            confirmation.before(nextOperation).queue()
        }
        
        nextOperation.rechainAfter(self).queue()
    }
}
