//
//  ToggleBlockUserOperation.swift
//  victorious
//
//  Created by Sharif Ahmed on 2/29/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

class ToggleBlockUserOperation: FetcherOperation {
    
    private let dependencyManager: VDependencyManager
    private let originViewController: UIViewController
    private let userId: Int
    let isUnblockOperation: Bool
    
    init( originViewController: UIViewController, dependencyManager: VDependencyManager, user: VUser, presentationCompletion: (()->())? ) {
        self.originViewController = originViewController
        self.dependencyManager = dependencyManager
        self.userId = user.remoteId.integerValue
        self.isUnblockOperation = user.isBlockedByMainUser?.boolValue == true
        
        super.init()
        
        ShowBlockUserConfirmationAlertOperation(originViewController: originViewController, dependencyManager: dependencyManager, shouldUnblockUser: isUnblockOperation, presentationCompletion: nil).before(self).queue()
    }
    
    override func main() {
        
        guard let confirmationOperation = dependencies.flatMap({ $0 as? ActionConfirmationOperation }).first
            where confirmationOperation.didConfirmAction else {
                return
        }
        
        if isUnblockOperation {
            UnblockUserOperation(userID: userId).rechainAfter(self).queue()
        } else {
            BlockUserOperation(userID: userId).rechainAfter(self).queue()
        }
    }
}
