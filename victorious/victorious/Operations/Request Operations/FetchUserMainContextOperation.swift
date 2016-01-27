//
//  FetchUserMainContextOperation.swift
//  victorious
//
//  Created by Michael Sena on 1/26/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

class FetchUserMainContextOperation: Operation {
    
    private let remoteID: Int
    
    let persistentStore: PersistentStoreType = PersistentStoreSelector.defaultPersistentStore
    
    var result: VUser?
    
    init(withRemoteID remoteID: Int) {
        self.remoteID = remoteID
    }
    
    override func start() {
        super.start()
        self.beganExecuting()
        
        persistentStore.mainContext.v_performBlock{ context in
            let mainQueueUser: VUser? = context.v_findObjects(["remoteId": self.remoteID]).first
            self.result = mainQueueUser
            self.finishedExecuting()
        }
    }
}
