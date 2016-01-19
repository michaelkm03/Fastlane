//
//  FetchUserOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 1/18/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

class FetchUserOperation: Operation {
    
    private let sourceUser: VictoriousIOSSDK.User
    
    let persistentStore: PersistentStoreType = PersistentStoreSelector.defaultPersistentStore
    
    var result: VUser?
    
    init( fromUser sourceUser: VictoriousIOSSDK.User) {
        self.sourceUser = sourceUser
    }
    
    override func start() {
        super.start()
        self.beganExecuting()
    
        persistentStore.createBackgroundContext().v_performBlockAndWait() { context in
            let persistentUser: VUser = context.v_findOrCreateObject([ "remoteId" : self.sourceUser.userID ])
            persistentUser.populate(fromSourceModel: self.sourceUser)
            context.v_save()
            
            let objectID = persistentUser.objectID
            self.persistentStore.mainContext.v_performBlock() { context in
                self.result = context.objectWithID( objectID ) as? VUser
                self.finishedExecuting()
            }
        }
    }
}
