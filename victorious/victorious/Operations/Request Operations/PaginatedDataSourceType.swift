//
//  PaginatedDataSourceType.swift
//  victorious
//
//  Created by Patrick Lynch on 1/13/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

/// Defines an object that responds to changes in the backing store of `PaginatedDataSource`.
@objc protocol PaginatedDataSourceDelegate: NSObjectProtocol {
    
    /// Called from a `PaginateddataSource` instance when new objects have been fetched and added to its backing store.
    /// The `oldValue` and `newValue` parameters are designed to allow calling code to
    /// precisely reload only what has changed instead of useing `reloadData()`.
    func paginatedDataSource( paginatedDataSource: PaginatedDataSource,
        didUpdateVisibleItemsFrom oldValue: NSOrderedSet,
        to newValue: NSOrderedSet)
    
    optional func paginatedDataSource( paginatedDataSource: PaginatedDataSource,
        didChangeStateFrom oldState: DataSourceState,
        to newState: DataSourceState)
}

/// Defines an object that manages PaginatedOperation instances by using them
/// to load pages worth of data and collect them in a backing store for a tableview
/// or collection view.
protocol PaginatedDataSourceType: class {
    
    var delegate: PaginatedDataSourceDelegate? { set get }
    
    /// The current state, which should be represented any UI
    var state: DataSourceState { get }
    
    /// The backing store for a collection or table view, i.e. what to show
    var visibleItems: NSOrderedSet { get }
    
    func cancelCurrentOperation()
    
    /// Clears the backing store (`visibleItems`) and calls appropriate delegate methods
    func unload()
    
    /// Uses the provided operation or a sebsequent operation create from the original operation
    /// (i.e. the one provided by calling the `createOperation` closure) to load a page of results
    /// from the network.  When finished, internal state changes and changes to the backing store
    /// may occur, which will in turn call the appropriate delegate methods.
    func loadPage<T: PaginatedOperation where T.PaginatedRequestType.PaginatorType : NumericPaginator>( pageType: VPageType,
        @noescape createOperation: () -> T,
        completion: ((operation: T?, error: NSError?) -> Void)? )
}
