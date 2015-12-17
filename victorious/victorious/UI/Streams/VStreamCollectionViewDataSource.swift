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
                let old = self.visibleStreamItems.array as? [VStreamItem] ?? []
                let new = operation.results
                
                let section = self.sectionIndexForContent()
                let combined = old + new
                let change = UICollectionView.Change(
                    deletedIndexPaths: nil,
                    insertedIndexPaths: new.flatMap { combined.indexOf($0) }.map { NSIndexPath(forItem: Int($0), inSection: section) }
                )
                self.visibleStreamItems = NSOrderedSet(array: combined)
                
                self.collectionView?.reloadData()
                
                //self.collectionView?.applyChange( change )
            }
            self.streamLoadOperation = operation
        }
    }
}

private extension UICollectionView {
    
    struct Change {
        let deletedIndexPaths:[NSIndexPath]?
        let insertedIndexPaths:[NSIndexPath]?
        
        var hasChanges: Bool {
            return self.deletedIndexPaths?.count > 0 || self.insertedIndexPaths?.count > 0
        }
    }
    
    func applyChange( change: Change ) {
        self.performBatchUpdates({
            
            if let insertedIndexPaths = change.insertedIndexPaths {
                self.insertItemsAtIndexPaths( insertedIndexPaths )
            }
            if let deletedIndexPaths = change.deletedIndexPaths {
                self.deleteItemsAtIndexPaths( deletedIndexPaths )
            }
        }, completion: nil)
    }
}
