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
@objc protocol PaginatedDataSourceDelegate {
    
    /// Called from a `PaginateddataSource` instance when new objects have been fetched and added to its backing store.
    /// The `oldValue` and `newValue` parameters are designed to allow calling code to
    /// precisely reload only what has changed instead of useing `reloadData()`.
    func paginatedDataSource( paginatedDataSource: PaginatedDataSource, didUpdateVisibleItemsFrom oldValue: NSOrderedSet, to newValue: NSOrderedSet)
}

/// A utility that abstracts the interaction between UI code and paginated `RequestOperation`s
/// into an API that is more concise and reuable between any paginated view controllers that have
/// a simple collection or table view layout.
@objc class PaginatedDataSource: NSObject {
    
    private typealias Filter = AnyObject -> Bool
    private var filters = [Filter]()
    
    private(set) var currentOperation: RequestOperation?
    private(set) var isLoading: Bool = false
    var clearsVisibleItemsBeforeLoadingFirstPage: Bool = false
    
    private(set) dynamic var visibleItems = NSOrderedSet() {
        didSet {
            if oldValue != visibleItems {
                self.delegate?.paginatedDataSource( self, didUpdateVisibleItemsFrom: oldValue, to: visibleItems )
            }
        }
    }
    
    private(set) var unfilteredItems = NSOrderedSet() {
        didSet {
            applyFilters()
        }
    }
    
    // MARK: - Public API
    
    var delegate: PaginatedDataSourceDelegate?
    
    func addFilter( filter: AnyObject -> Bool  ) {
        filters.append( filter )
        applyFilters()
    }
    
    func resetFilters() {
        filters = []
        applyFilters()
    }
    
    func unload() {
        unfilteredItems = NSOrderedSet()
        visibleItems = NSOrderedSet()
    }
    
    func cancelCurrentOperation() {
        currentOperation?.cancel()
        currentOperation = nil
    }
    
    func loadPage<T: PaginatedOperation>( pageType: VPageType, @noescape createOperation: () -> T, completion: ((operation: T?, error: NSError?) -> Void)? = nil ) {
        
        guard !isLoading else {
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
            self.isLoading = true
            
            if clearsVisibleItemsBeforeLoadingFirstPage && pageType == .First {
                unload()
            }
            operation.queue() { error in
                self.isLoading = false
                self.onOperationComplete( typedOperation, pageType: pageType, error: error)
                completion?( operation: typedOperation, error: error )
            }
        }
        
        self.currentOperation = operationToQueue
    }
    
    // MARK: - Private helpers
    
    private func onOperationComplete<T: PaginatedOperation>( operation: T, pageType: VPageType, error: NSError? ) {
        guard let results = operation.results else {
            return
        }
        
        if operation.didResetResults {
            self.unfilteredItems = NSOrderedSet().v_orderedSet( byAddingObjects: results, forPageType: pageType)
        }
        
        if !results.isEmpty {
            self.unfilteredItems = self.unfilteredItems.v_orderedSet( byAddingObjects: results, forPageType: pageType)
        }
    }
    
    private func applyFilters() {
        var items = unfilteredItems.array
        for filter in filters {
            items = items.filter { filter($0) }
        }
        visibleItems = NSOrderedSet(array: items)
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
