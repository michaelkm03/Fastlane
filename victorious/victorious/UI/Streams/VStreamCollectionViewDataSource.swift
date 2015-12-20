//
//  VStreamCollectionViewDataSource+Networking.swift
//  victorious
//
//  Created by Patrick Lynch on 11/16/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import UIKit
import VictoriousIOSSDK

public extension VStreamCollectionViewDataSource {
    
    var isLoading: Bool {
        return self.pageLoader.isLoading
    }
    
    /// The primary way to load a stream.
    ///
    /// -parameter pageType Which page of this paginatined method should be loaded (see VPageType).
    public func loadPage( pageType: VPageType, completion:(NSError?)->()) {
        guard let apiPath = self.stream?.apiPath else {
            return
        }
        
        self.pageLoader.loadPage( pageType,
            createOperation: {
                return StreamOperation(apiPath: (apiPath) )
            },
            completion: { (operation, error) in
                if let error = error {
                    completion( error )
                
                } else if let operation = operation {
                    let existing = self.visibleStreamItems
                    let loaded = operation.results
                    self.visibleStreamItems = NSOrderedSet(array: existing + loaded)
                    completion( nil )
                }
            }
        )
    }
    
    public func removeStreamItem(streamItem: VStreamItem) {
        let persistentStore: PersistentStoreType = MainPersistentStore()
        persistentStore.mainContext.v_performBlock() { context in
            self.stream?.v_removeObject( streamItem, from: "streamItems" )
            context.v_save()
            
            let updatedItems = self.visibleStreamItems.array.flatMap { $0 as? VStreamItem }.filter { $0 != streamItem }
            self.visibleStreamItems = NSOrderedSet( array: updatedItems)
        }
    }
    
    public func unloadStream() {
        let persistentStore: PersistentStoreType = MainPersistentStore()
        persistentStore.mainContext.v_performBlock() { context in
            self.stream?.v_removeAllObjects( from: "streamItems" )
            context.v_save()
            
            self.visibleStreamItems = NSOrderedSet()
        }
    }
}
