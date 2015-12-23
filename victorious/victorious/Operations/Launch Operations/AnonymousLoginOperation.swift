//
//  AnonymousLoginOperation.swift
//  victorious
//
//  Created by Tian Lan on 12/7/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation

class AnonymousLoginOperation: Operation {
    
    private let persistentStore: PersistentStoreType = MainPersistentStore()
    
    override func start() {
        super.start()
        
        defer {
            finishedExecuting()
        }
        
        beganExecuting()
        
        guard let retriedIDString = AgeGate.anonymousUserID(),
            let retrivedUserID = Int64(retriedIDString) else {
                return
        }
        let anonymousID = NSNumber(longLong: retrivedUserID)
        let anonymousToken = AgeGate.anonymousUserToken()
        let anonymousLoginType = VLoginType.Anonymous
        
        persistentStore.asyncFromBackground() { context in
            let user: VUser = context.findOrCreateObject([ "remoteId" : anonymousID ])
            user.loginType = anonymousLoginType.rawValue
            user.token = anonymousToken
            
            if user.status == nil {
                user.status = "anonymous"
            }
            
            user.setAsCurrentUser()
            context.saveChanges()
            self.finishedExecuting()
        }
    }
}
