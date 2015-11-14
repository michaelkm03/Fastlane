//
//  VSettingsViewController+Swift.swift
//  victorious
//
//  Created by Patrick Lynch on 11/13/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation

extension VSettingsViewController {
    
    func queueLogoutOperation() -> NSOperation {
        let operation = LogoutLocally()
        
        // Execute this oepration synchronously on main thread to effect logout state changes immediately
        NSOperationQueue.mainQueue().addOperation( operation )
        
        return operation
    }
}