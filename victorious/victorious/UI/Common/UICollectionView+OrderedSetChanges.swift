//
//  UICollectionView+OrderedSetChanges.swift
//  victorious
//
//  Created by Patrick Lynch on 12/23/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import UIKit

public extension UICollectionView {
    
    /// Inserts and/or removes index paths based on difference between arguments `oldValue` and `newValue`.
    public func v_applyChangeInSection(section: NSInteger, from oldValue:NSOrderedSet, to newValue: NSOrderedSet ) {
        
        guard newValue.count == 0 || oldValue.count == 0 else {
            self.reloadSections( NSIndexSet(index: section) )
            return
        }
        
        var insertedIndexPaths = [NSIndexPath]()
        for item in newValue where !oldValue.containsObject( item ) {
            let index = newValue.indexOfObject( item )
            insertedIndexPaths.append( NSIndexPath(forItem: index, inSection: section) )
        }
        
        var deletedIndexPaths = [NSIndexPath]()
        for item in oldValue where !newValue.containsObject( item ) {
            let index = oldValue.indexOfObject( item )
            deletedIndexPaths.append( NSIndexPath(forItem: index, inSection: section) )
        }
        
        UIView.performWithoutAnimation() {
            self.performBatchUpdates({
                self.insertItemsAtIndexPaths( insertedIndexPaths )
                self.deleteItemsAtIndexPaths( deletedIndexPaths )
            }, completion: nil)
        }
    }
}

public extension UITableView {
    
    /// Inserts and/or removes index paths based on difference between arguments `oldValue` and `newValue`.
    public func v_applyChangeInSection(section: NSInteger, from oldValue:NSOrderedSet, to newValue: NSOrderedSet ) {
        
        guard newValue.count == 0 || oldValue.count == 0 else {
            self.reloadSections( NSIndexSet(index: section), withRowAnimation: .Automatic)
            return
        }
        
        var insertedIndexPaths = [NSIndexPath]()
        for item in newValue where !oldValue.containsObject( item ) {
            let index = newValue.indexOfObject( item )
            insertedIndexPaths.append( NSIndexPath(forRow: index, inSection: section) )
        }
        
        var deletedIndexPaths = [NSIndexPath]()
        for item in oldValue where !newValue.containsObject( item ) {
            let index = oldValue.indexOfObject( item )
            deletedIndexPaths.append( NSIndexPath(forRow: index, inSection: section) )
        }
        
        self.insertRowsAtIndexPaths( insertedIndexPaths, withRowAnimation: .Automatic)
        self.deleteRowsAtIndexPaths( deletedIndexPaths, withRowAnimation: .Automatic)
    }
}
