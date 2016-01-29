//
//  UITableView+OrderedSet.swift
//  victorious
//
//  Created by Patrick Lynch on 1/19/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

public extension UITableView {
    
    /// Inserts and/or removes index paths based on difference between arguments `oldValue` and `newValue`.
    public func v_applyChangeInSection(section: NSInteger, from oldValue:NSOrderedSet, to newValue: NSOrderedSet ) {
        
        guard newValue.count != 0 && oldValue.count != 0 else {
            UIView.performWithoutAnimation() {
                self.reloadSections( NSIndexSet(index: section), withRowAnimation: .None)
            }
            return
        }
        
        var insertedIndexPaths = [NSIndexPath]()
        for item in newValue  {
            let newIndex = newValue.indexOfObject( item )
            if oldValue.indexOfObject(item) == newIndex {
                continue
            }
            insertedIndexPaths.append( NSIndexPath(forRow: newIndex, inSection: section) )
        }
        
        var deletedIndexPaths = [NSIndexPath]()
        for item in oldValue {
            let oldIndex = oldValue.indexOfObject( item )
            if oldIndex == newValue.indexOfObject(item) {
                continue
            }
            deletedIndexPaths.append( NSIndexPath(forRow: oldIndex, inSection: section) )
        }
        
        self.beginUpdates()
        self.deleteRowsAtIndexPaths( deletedIndexPaths, withRowAnimation: .Bottom)
        self.insertRowsAtIndexPaths( insertedIndexPaths, withRowAnimation: .Top)
        self.endUpdates()
    }
}