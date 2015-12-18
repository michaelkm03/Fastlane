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
    
    /// The primary way to load a stream.
    ///
    /// -parameter pageType Which page of this paginatined method should be loaded (see VPageType).
    public func loadPage( pageType: VPageType, withSuccess success:()->(), failure:(NSError?)->()) {
        
        let nextOperation: StreamOperation?
        switch pageType {
        case .First:
            if let apiPath = self.stream?.apiPath  {
                nextOperation = StreamOperation(apiPath: (apiPath) )
            } else {
                nextOperation = nil
            }
        case .Next:
            nextOperation = self.streamLoadOperation?.next()
        case .Previous:
            nextOperation = self.streamLoadOperation?.prev()
        }
        
        if let operation = nextOperation {
            self.isLoading = true
            operation.queue() { error in
                self.isLoading = false
                if let error = error {
                    failure( error )
                } else {
                    success()
                }
                let existing = self.visibleStreamItems
                let loaded = operation.results
                self.visibleStreamItems = NSOrderedSet(array: existing + loaded)
            }
            self.streamLoadOperation = operation
        }
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
