//
//  CollectionType.swift
//  victorious
//
//  Created by Jarod Long on 6/29/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

extension Collection {
    /// Returns an element selected from `self`.
    ///
    /// `chooseBetween` should return true when `potentialSelection` is preferred over `currentSelection`.
    ///
    /// The first time `chooseBetween` is called, `currentSelection` and `potentialSelection` will be the first and
    /// second elements of the collection respectively. Each subsequent call will return the next element in the list
    /// for `potentialSelection`. Returning true will cause `potentialSelection` to be the new value for
    /// `currentSelection`.
    ///
    /// Returns nil iff the collection is empty, and returns the first element in the collection if the collection
    /// contains exactly one element. `chooseBetween` will never be called when `self.count` <= 1.
    ///
    /// - COMPLEXITY: O(`self.count`)
    ///
    func select(_ chooseBetween: (_ currentSelection: Iterator.Element, _ potentialSelection: Iterator.Element) -> Bool) -> Iterator.Element? {
        var selection: Iterator.Element?
        
        for element in self {
            if let currentSelection = selection {
                if chooseBetween(currentSelection, element) {
                    selection = element
                }
            }
            else {
                selection = element
            }
        }
        
        return selection
    }
}
