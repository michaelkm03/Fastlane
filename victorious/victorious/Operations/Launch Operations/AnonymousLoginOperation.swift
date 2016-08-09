//
//  AnonymousLoginOperation.swift
//  victorious
//
//  Created by Tian Lan on 12/7/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation

class AnonymousLoginOperation: BackgroundOperation {
    
    private let persistentStore: PersistentStoreType = PersistentStoreSelector.defaultPersistentStore
    
    override func start() {
        super.start()
        
        defer {
            finishedExecuting()
        }
        
        beganExecuting()
        
        guard let anonymousID = AgeGate.anonymousUserID() else {
            return
        }
        let anonymousToken = AgeGate.anonymousUserToken()
        let anonymousLoginType = VLoginType.Anonymous
        
        persistentStore.mainContext.v_performBlockAndWait() { context in
            let user: VUser = context.v_findOrCreateObject([ "remoteId" : anonymousID ])
            user.loginType = anonymousLoginType.rawValue
            user.token = anonymousToken
            user.isVIPSubscriber = false
            user.setAsCurrentUser()
            context.v_save()
            self.finishedExecuting()
        }
    }
}
