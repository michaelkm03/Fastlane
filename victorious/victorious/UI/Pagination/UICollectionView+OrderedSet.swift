//
//  UICollectionView+OrderedSet.swift
//  victorious
//
//  Created by Patrick Lynch on 12/23/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import UIKit

public extension UICollectionView {
    
    public func v_applyChangeInSection(section: NSInteger, from oldValue:NSOrderedSet, to newValue: NSOrderedSet) {
        self.v_applyChangeInSection(section, from: oldValue, to: newValue, animated:false)
    }
    
    /// Inserts and/or removes index paths based on difference between arguments `oldValue` and `newValue`.
    public func v_applyChangeInSection(section: NSInteger, from oldValue:NSOrderedSet, to newValue: NSOrderedSet, animated: Bool) {
        
        guard !(newValue.count == 0 || oldValue.count == 0) else {
            let performChangesBlock = {
                self.reloadSections( NSIndexSet(index: section) )
            }
            if (animated && oldValue.count > 0) || (animated && newValue.count == 1) {
                performChangesBlock()
            } else {
                UIView.performWithoutAnimation(performChangesBlock)
            }
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
        
        let performChangesBlock = {
            self.performBatchUpdates({
                self.insertItemsAtIndexPaths( insertedIndexPaths )
                self.deleteItemsAtIndexPaths( deletedIndexPaths )
            }, completion: nil)
        }
        
        if animated {
            performChangesBlock()
        } else {
            UIView.performWithoutAnimation(performChangesBlock)
        }
    }
}
