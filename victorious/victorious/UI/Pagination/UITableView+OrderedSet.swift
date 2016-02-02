//
//  UITableView+OrderedSet.swift
//  victorious
//
//  Created by Patrick Lynch on 1/19/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

public extension UITableView {
    
    public func v_applyChangeInSection(section: NSInteger, from oldValue:NSOrderedSet, to newValue: NSOrderedSet) {
        self.v_applyChangeInSection(section, from: oldValue, to: newValue, animated:false)
    }
    
    /// Inserts and/or removes index paths based on difference between arguments `oldValue` and `newValue`.
    public func v_applyChangeInSection(section: NSInteger, from oldValue:NSOrderedSet, to newValue: NSOrderedSet, animated: Bool) {
        
        guard !(newValue.count == 0 || oldValue.count == 0) else {
            let performChangesBlock = {
                self.beginUpdates()
                self.reloadSections( NSIndexSet(index: section), withRowAnimation: .None)
                self.endUpdates()
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
            insertedIndexPaths.append( NSIndexPath(forRow: index, inSection: section) )
        }
        
        var deletedIndexPaths = [NSIndexPath]()
        for item in oldValue where !newValue.containsObject( item ) {
            let index = oldValue.indexOfObject( item )
            deletedIndexPaths.append( NSIndexPath(forRow: index, inSection: section) )
        }
        
        let performChangesBlock = {
            self.beginUpdates()
            self.deleteRowsAtIndexPaths( deletedIndexPaths, withRowAnimation: .Bottom)
            self.insertRowsAtIndexPaths( insertedIndexPaths, withRowAnimation: .Top)
            self.endUpdates()
        }
        
        if animated {
            performChangesBlock()
        } else {
            UIView.performWithoutAnimation(performChangesBlock)
        }
    }
}