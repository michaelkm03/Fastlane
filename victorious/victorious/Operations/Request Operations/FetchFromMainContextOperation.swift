//
//  FetchFromMainContextOperation.swift
//  victorious
//
//  Created by Michael Sena on 1/26/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation
import CoreData

class FetchFromMainContextOperation: FetcherOperation {
    
    private let entityName: String
    private let predicate: NSPredicate
    
    init(entityName: String, predicate: NSPredicate) {
        self.entityName = entityName
        self.predicate = predicate
        super.init()
    }
    
    override func main() {
        persistentStore.mainContext.v_performBlockAndWait() { context in
            let request = NSFetchRequest(entityName: self.entityName)
            request.returnsObjectsAsFaults = false
            request.predicate = self.predicate
            
            do {
                self.results = try context.executeFetchRequest( request )
            } catch {
                VLog( "Error: \(error)" )
            }
        }
    }
}
