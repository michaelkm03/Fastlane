//
//  AnonymousLoginForKidOperation.swift
//  victorious
//
//  Created by Tian Lan on 12/7/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation

class AnonymousLoginForKidOperation: Operation {
    override init() {
        super.init()
        qualityOfService = .UserInteractive
    }
    
    override func start() {
        super.start()
        
        if cancelled {
            finishedExecuting()
            return
        }
        
        beganExecuting()
        
        dispatch_async(dispatch_get_main_queue()) {
            VObjectManager.sharedManager().loginWithAnonymousUserToken()
            self.finishedExecuting()
        }
    }
}
