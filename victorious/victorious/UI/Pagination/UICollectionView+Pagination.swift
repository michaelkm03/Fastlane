//
//  UICollectionView+Pagination.swift
//  victorious
//
//  Created by Patrick Lynch on 2/19/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

extension UICollectionView {
    func v_applyChangeInSection(_ section: NSInteger, from oldValue: NSOrderedSet, to newValue: NSOrderedSet) {
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
    func v_applyChangeInSection(_ section: NSInteger, from oldValue: NSOrderedSet, to newValue: NSOrderedSet, animated: Bool, completion: (() -> ())? = nil) {
        
        guard !(newValue.count == 0 || oldValue.count == 0) else {
            let performChangesBlock = {
                self.reloadSections( IndexSet(integer: section) )
            }
            if (animated && oldValue.count > 0) || (animated && newValue.count == 1) {
                performChangesBlock()
            } else {
                UIView.performWithoutAnimation(performChangesBlock)
            }
            completion?()
            return
        }
        
        var insertedIndexPaths = [IndexPath]()
        for item in newValue where !oldValue.contains( item ) {
            let index = newValue.index( of: item )
            insertedIndexPaths.append( IndexPath(item: index, section: section) )
        }
        
        var deletedIndexPaths = [IndexPath]()
        for item in oldValue where !newValue.contains( item ) {
            let index = oldValue.index( of: item )
            deletedIndexPaths.append( IndexPath(item: index, section: section) )
        }
        
        let performChangesBlock = {
            self.performBatchUpdates(
                {
                    self.insertItems( at: insertedIndexPaths )
                    self.deleteItems( at: deletedIndexPaths )
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
