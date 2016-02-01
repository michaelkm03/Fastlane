//
//  FetchManagedObjectsOnMainContextOperation.swift
//  victorious
//
//  Created by Michael Sena on 1/26/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

class FetchManagedObjectsOnMainContextOperation: Operation {
    
    private let persistentStore: PersistentStoreType = PersistentStoreSelector.defaultPersistentStore
    private let entityName: String
    private let queryDictionary: [String: AnyObject]
    
    var result: [AnyObject]?
    
    init(withEntityName entityName: String, queryDictionary: [String: AnyObject]) {
        self.entityName = entityName
        self.queryDictionary = queryDictionary
        super.init()
    }
    
    override func start() {
        super.start()
        self.beganExecuting()
        persistentStore.mainContext.v_performBlock{context in
            self.result = context.v_findObjectsWithEntityName(self.entityName, queryDictionary: self.queryDictionary)
            self.finishedExecuting()
        }
    }
    
}
