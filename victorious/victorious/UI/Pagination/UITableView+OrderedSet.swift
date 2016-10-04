//
//  UITableView+OrderedSet.swift
//  victorious
//
//  Created by Patrick Lynch on 1/19/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

public extension UITableView {
    
    public func v_applyChangeInSection(_ section: NSInteger, from oldValue: NSOrderedSet, to newValue: NSOrderedSet) {
        self.v_applyChangeInSection(section, from: oldValue, to: newValue, animated: false)
    }
    
    /// Inserts and/or removes index paths based on difference between arguments `oldValue` and `newValue`.
    public func v_applyChangeInSection(_ section: NSInteger, from oldValue: NSOrderedSet, to newValue: NSOrderedSet, animated: Bool) {
        guard !(newValue.count == 0 || oldValue.count == 0) else {
            let performChangesBlock = {
                self.beginUpdates()
                self.reloadSections(IndexSet(integer: section), with: .none)
                self.endUpdates()
            }
            if (animated && oldValue.count > 0) || (animated && newValue.count == 1) {
                performChangesBlock()
            } else {
                UIView.performWithoutAnimation(performChangesBlock)
            }
            return
        }
        
        var insertedIndexPaths = [IndexPath]()
        for item in newValue where !oldValue.contains( item ) {
            let index = newValue.index( of: item )
            insertedIndexPaths.append( IndexPath(row: index, section: section) )
        }
        
        var deletedIndexPaths = [IndexPath]()
        for item in oldValue where !newValue.contains( item ) {
            let index = oldValue.index( of: item )
            deletedIndexPaths.append( IndexPath(row: index, section: section) )
        }
        
        let performChangesBlock = {
            self.beginUpdates()
            self.deleteRows( at: deletedIndexPaths, with: .bottom)
            self.insertRows( at: insertedIndexPaths, with: .top)
            self.endUpdates()
        }
        
        if animated {
            performChangesBlock()
        } else {
            UIView.performWithoutAnimation(performChangesBlock)
        }
    }
}
