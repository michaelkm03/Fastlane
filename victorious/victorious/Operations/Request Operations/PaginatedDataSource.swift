//
//  PaginatedDataSource.swift
//  victorious
//
//  Created by Patrick Lynch on 12/19/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation

// TODO: Anbstract into protocol!
// TODO: Finish tests for

/// Defines an object that responds to changes in the backing store of `PaginatedDataSource`.
@objc protocol PaginatedDataSourceDelegate: NSObjectProtocol {
    
    /// Called from a `PaginateddataSource` instance when new objects have been fetched and added to its backing store.
    /// The `oldValue` and `newValue` parameters are designed to allow calling code to
    /// precisely reload only what has changed instead of useing `reloadData()`.
    func paginatedDataSource( paginatedDataSource: PaginatedDataSource, didUpdateVisibleItemsFrom oldValue: NSOrderedSet, to newValue: NSOrderedSet)
    
    optional func paginatedDataSource( paginatedDataSource: PaginatedDataSource, didChangeStateFrom oldState: DataSourceState, to newState: DataSourceState)
}

@objc enum DataSourceState: Int {
    case Loading
    case Cleared
    case NoResults
    case Results
    case Error
}

/// A utility that abstracts the interaction between UI code and paginated `RequestOperation`s
/// into an API that is more concise and reuable between any paginated view controllers that have
/// a simple collection or table view layout.
@objc public class PaginatedDataSource: NSObject {
    private(set) var currentOperation: RequestOperation?
    
    private(set) var state: DataSourceState = .Cleared {
        didSet {
            if oldValue != state {
                self.delegate?.paginatedDataSource?(self, didChangeStateFrom: oldValue, to: state)
            }
        }
    }
    
    func isLoading() -> Bool {
        return state == .Loading
    }
    
    /// Tells the data source to unload all items from its `visibleItems` backing store
    /// whenever a page is loaded with a VPageType.First value specified.  This is useful for
    /// search-style data sources that should clear when a new search has begun.
    var clearsVisibleItemsBeforeLoadingFirstPage: Bool = false
    
    private(set) dynamic var visibleItems = NSOrderedSet() {
        didSet {
            if oldValue != visibleItems {
                self.delegate?.paginatedDataSource( self, didUpdateVisibleItemsFrom: oldValue, to: visibleItems )
            }
        }
    }
    
    // MARK: - Public API
    
    var delegate: PaginatedDataSourceDelegate?
    
    func unload() {
        cancelCurrentOperation()
        visibleItems = NSOrderedSet()
    }
    
    func cancelCurrentOperation() {
        currentOperation?.cancel()
        currentOperation = nil
    }
    
    func loadPage<T: PaginatedOperation>( pageType: VPageType, @noescape createOperation: () -> T, completion: ((operation: T?, error: NSError?) -> Void)? = nil ) {
        
        guard state != .Loading else {
            return
        }
        
        let operationToQueue: RequestOperation?
        switch pageType {
            
        case .First:
            operationToQueue = createOperation() as? RequestOperation
            
        case .Next:
            operationToQueue = (currentOperation as? T)?.next() as? RequestOperation
            
        case .Previous:
            operationToQueue = (currentOperation as? T)?.prev() as? RequestOperation
        }
        
        if let operation = operationToQueue, let typedOperation = operationToQueue as? T {
            self.state = .Loading
            operation.queue() { error in
                self.onOperationComplete( typedOperation, pageType: pageType, error: error)
                if error != nil {
                    self.state = .Error
                } else {
                    self.state = self.visibleItems.count == 0 ? .NoResults : .Results
                }
                completion?( operation: typedOperation, error: error )
            }
        }
        
        self.currentOperation = operationToQueue
    }
    
    // MARK: - Private helpers
    
    private func onOperationComplete<T: PaginatedOperation>( operation: T, pageType: VPageType, error: NSError? ) {
        guard let results = operation.results where !results.isEmpty else {
            return
        }
        
        self.visibleItems = self.visibleItems.v_orderedSet(byAddingObjects: results, forPageType: pageType)
    }
}

private extension NSOrderedSet {
    
    func v_orderedSet( byAddingObjects objects: [AnyObject], forPageType pageType: VPageType ) -> NSOrderedSet {
        switch pageType {
            
        case .First: //< reset
            return NSOrderedSet(array: objects)
            
        case .Next: //< apend
            return NSOrderedSet(array: self.array + objects)
            
        case .Previous: //< prepend
            return NSOrderedSet(array: objects + self.array)
        }
    }
}
