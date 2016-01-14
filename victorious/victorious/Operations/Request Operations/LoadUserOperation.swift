//
//  LoadUserOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 1/13/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

class LoadUserOperation: Operation {
    
    var persistentStore: PersistentStoreType = PersistentStoreSelector.defaultPersistentStore
    
    let userID: Int
    
    var result: VUser?
    
    required init(userID: Int) {
        self.userID = userID
    }
    
    override func start() {
        super.start()
        
        self.beganExecuting()
        
        self.result = persistentStore.mainContext.v_performBlockAndWait() { context in
            let uniqueInfo = [ "remoteId" : self.userID ]
            return context.v_findObjects( uniqueInfo ).first as? VUser
        }
        
        self.finishedExecuting()
    }
}
