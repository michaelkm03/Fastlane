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
        let isBlocked: Bool = persistentStore.mainContext.v_performBlockAndWait() { context in
            if let user: VUser = context.v_findObjects(["remoteId" : self.userID]).first {
                return user.isBlockedByMainUser.boolValue ?? false
            }
            return false
        }
        
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
