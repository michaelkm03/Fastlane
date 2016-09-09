//
//  PaginatedDataSourceType.swift
//  victorious
//
//  Created by Patrick Lynch on 1/13/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

/// Defines an object that manages PaginatedOperation instances by using them
/// to load pages worth of data and collect them in a backing store for a tableview
/// or collection view.
@objc protocol PaginatedDataSourceType: class {

    var delegate: VPaginatedDataSourceDelegate? { set get }
    
    /// The current state, which should be represented any UI
    var state: VDataSourceState { get }
    
    /// The backing store for a collection or table view, i.e. what to show
    var visibleItems: NSOrderedSet { get }
    
    /// Attempt to halt the execution and bypass completion logic of any
    /// active operation
    func cancelCurrentOperation()
    
    /// Clears the backing store (`visibleItems`) and calls appropriate delegate methods
    func unload()
    
    /// Convenience method that indiates if the `state` property holds the case value
    /// that represents the loading state.
    func isLoading() -> Bool
    
    /// Remove any items that are marked for deletion
    func removeDeletedItems()
}
