//
//  FetchUserOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 1/18/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

class FetchUserOperation: BackgroundOperation {
    
    private let userID: Int
    private let sourceUser: VictoriousIOSSDK.User?
    
    let persistentStore: PersistentStoreType = PersistentStoreSelector.defaultPersistentStore
    
    var result: VUser?
    
    init( userID: Int, sourceUser: VictoriousIOSSDK.User?) {
        self.userID = userID
        self.sourceUser = sourceUser
    }
    
    convenience init( sourceUser: VictoriousIOSSDK.User) {
        self.init( userID: sourceUser.id, sourceUser: sourceUser )
    }
    
    convenience init( userID: Int) {
        self.init( userID: userID, sourceUser: nil )
    }
    
    override func start() {
        super.start()
        self.beganExecuting()
        
        persistentStore.createBackgroundContext().v_performBlockAndWait() { context in
            let persistentUser: VUser = context.v_findOrCreateObject([ "remoteId" : self.userID ])
            if let sourceUser = self.sourceUser {
                persistentUser.populate(fromSourceModel: sourceUser)
            }
            context.v_save()
            
            let objectID = persistentUser.objectID
            self.persistentStore.mainContext.v_performBlock() { context in
                self.result = context.objectWithID( objectID ) as? VUser
                self.finishedExecuting()
            }
        }
    }
}
