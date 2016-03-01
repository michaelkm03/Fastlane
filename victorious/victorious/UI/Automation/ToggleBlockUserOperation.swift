//
//  ToggleBlockUserOperation.swift
//  victorious
//
//  Created by Sharif Ahmed on 2/29/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

class ToggleBlockUserOperation: FetcherOperation, ActionConfirmationOperation {
    
    private let dependencyManager: VDependencyManager
    private let originViewController: UIViewController
    private let userId: Int
    private(set) var didConfirmAction: Bool = false
    let isUnblockOperation: Bool
    
    init( originViewController: UIViewController, dependencyManager: VDependencyManager, user: VUser ) {
        self.originViewController = originViewController
        self.dependencyManager = dependencyManager
        self.userId = user.remoteId.integerValue
        self.isUnblockOperation = user.isBlockedByMainUser?.boolValue == true
        
        super.init()
        
        ShowBlockUserConfirmationAlertOperation(originViewController: originViewController, dependencyManager: dependencyManager, shouldUnblockUser: isUnblockOperation).before(self).queue()
    }
    
    override func main() {
        
        guard let confirmationOperation = dependencies.flatMap({ $0 as? ActionConfirmationOperation }).first
            where confirmationOperation.didConfirmAction else {
                return
        }
        
        didConfirmAction = true
        if isUnblockOperation {
            UnblockUserOperation(userID: userId).rechainAfter(self).queue()
        } else {
            BlockUserOperation(userID: userId).rechainAfter(self).queue()
        }
    }
}
