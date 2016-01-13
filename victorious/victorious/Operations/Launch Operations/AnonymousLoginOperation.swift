//
//  AnonymousLoginOperation.swift
//  victorious
//
//  Created by Tian Lan on 12/7/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation

class AnonymousLoginOperation: Operation {
    
    private let persistentStore: PersistentStoreType = PersistentStoreSelector.defaultPersistentStore
    
    override func start() {
        super.start()
        
        defer {
            finishedExecuting()
        }
        
        beganExecuting()
        
        guard let retriedIDString = AgeGate.anonymousUserID(),
            let anonymousID = Int(retriedIDString) else {
                return
        }
        let anonymousToken = AgeGate.anonymousUserToken()
        let anonymousLoginType = VLoginType.Anonymous
        
        persistentStore.backgroundContext.v_performBlock { context in
            let user: VUser = context.v_findOrCreateObject([ "remoteId" : anonymousID ])
            user.loginType = anonymousLoginType.rawValue
            user.token = anonymousToken
            
            if user.status == nil {
                user.status = "anonymous"
            }
            
            user.setAsCurrentUser()
            context.v_save()
            self.finishedExecuting()
        }
    }
}
