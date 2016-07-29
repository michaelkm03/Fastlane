//
//  UICollectionView+Pagination.swift
//  victorious
//
//  Created by Patrick Lynch on 2/19/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

extension UICollectionView {
    func v_applyChangeInSection(section: NSInteger, from oldValue: NSOrderedSet, to newValue: NSOrderedSet) {
        self.v_applyChangeInSection(section, from: oldValue, to: newValue, animated: false, completion: nil)
    }
    
    func v_reloadForPreviousPage() {
        
        // Because we're scrolling up in this view controller, we need to do a bit of
        // careful reloading and scroll position adjustment when loading next pages
        let oldContentSize = contentSize
        let oldOffset = contentOffset
        
        // Must call reloadData() to get contentSize to update instantly
        reloadData()
        
        let newContentSize = contentSize
        let newOffset = CGPoint(x: 0, y: oldOffset.y + (newContentSize.height - oldContentSize.height) )
        setContentOffset(newOffset, animated: false)
    }
    
    /// Inserts and/or removes index paths based on difference between arguments `oldValue` and `newValue`.
    func v_applyChangeInSection(section: NSInteger, from oldValue: NSOrderedSet, to newValue: NSOrderedSet, animated: Bool, completion: (() -> ())? = nil) {
        
        guard !(newValue.count == 0 || oldValue.count == 0) else {
            let performChangesBlock = {
                self.reloadSections( NSIndexSet(index: section) )
            }
            if (animated && oldValue.count > 0) || (animated && newValue.count == 1) {
                performChangesBlock()
            } else {
                UIView.performWithoutAnimation(performChangesBlock)
            }
            completion?()
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
            self.performBatchUpdates(
                {
                    self.insertItemsAtIndexPaths( insertedIndexPaths )
                    self.deleteItemsAtIndexPaths( deletedIndexPaths )
                },
                completion: { _ in
                    completion?()
                }
            )
        }
        
        if animated {
            performChangesBlock()
        } else {
            UIView.performWithoutAnimation(performChangesBlock)
        }
    }
}
