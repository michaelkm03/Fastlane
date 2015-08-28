//
//  Shelf+Fetcher.swift
//  victorious
//
//  Created by Sharif Ahmed on 8/28/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import Foundation

extension Shelf {
    
    /// Returns true when a shelf and its content are identical to this shelf
    func isEqualTo(shelf: Shelf?) -> Bool {
        if self == shelf,
            let newStreamItems = shelf?.streamItems
            where streamItems.isEqualToOrderedSet(newStreamItems) {
                //The shelf AND its content are the same, no need to update
                return true
        }
        return false
    }
}
