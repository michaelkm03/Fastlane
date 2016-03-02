//
//  PaginatedDataSource.swift
//  victorious
//
//  Created by Patrick Lynch on 12/19/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

/// A utility that abstracts the interaction between UI code and paginated `FetcherOperation`s
/// into an API that is more concise and reuable between any paginated view controllers that have
/// a simple collection or table view layout.
@objc public class PaginatedDataSource: NSObject, PaginatedDataSourceType, GenericPaginatedDataSourceType {
    
    // Keeps a reference without retaining; avoids needing [weak self] when queueing
    private(set) weak var currentPaginatedRequestOperation: NSOperation?
    private(set) weak var currentLocalOperation: NSOperation?
    
    /// Determines how many visible items are allowed before older items are purged.
    /// Default is 0, which indicates no limit.
    var maxVisibleItems: Int = 0
    
    private(set) var state: VDataSourceState = .Cleared {
        didSet {
            if oldValue != state {
                self.delegate?.paginatedDataSource?(self, didChangeStateFrom: oldValue, to: state)
            }
        }
    }
    
    var shouldStashNewContent: Bool = false {
        didSet {
            if !shouldStashNewContent && stashedItems.count > 0 {
                visibleItems = NSOrderedSet(array: visibleItems.array + stashedItems.array)
            }
        }
    }
    
    var shouldShowNextPageActivity: Bool {
        return state == .Loading && visibleItems.count > 0
    }
    
    // Tracks page numbers already loaded to prevent re-loading pages unecessarily
    private var pagesLoaded = Set<Int>()
    
    func isLoading() -> Bool {
        return state == .Loading
    }
    
    private(set) var stashedItems = NSOrderedSet() {
        didSet {
            guard oldValue != stashedItems else {
                return
            }
            if stashedItems.count == 0 {
                shouldStashNewContent = false
            }
            delegate?.paginatedDataSource?(self, didUpdateStashedItemsFrom: oldValue, to: stashedItems)
        }
    }
    
    private var isPurging = false
    private(set) var visibleItems: NSOrderedSet {
        set {
            // Unstash only any newly added visible items that are current stashed
            let predicate1 = NSPredicate() { newValue.containsObject( $0.0 ) }
            let toUnstash = stashedItems.filteredOrderedSetUsingPredicate( predicate1 )
            let predicate2 = NSPredicate() { !toUnstash.containsObject( $0.0 ) }
            stashedItems = stashedItems.filteredOrderedSetUsingPredicate( predicate2 )
            
            // Set the visible items after sorting by displayOrder
            let array = newValue.array as? [PaginatedObjectType] ?? []
            let sortedArray = array.sort { $0.displayOrder.compare($1.displayOrder) == .OrderedAscending }
            _visibleItems = NSOrderedSet(array: sortedArray)
        }
        get {
            return _visibleItems
        }
    }
    
    private(set) var _visibleItems = NSOrderedSet() {
        didSet {
            guard oldValue != visibleItems else {
                return
            }
            
            if isPurging {
                delegate?.paginatedDataSource?( self, didPurgeVisibleItemsFrom: oldValue, to: visibleItems )
            } else {
                delegate?.paginatedDataSource( self, didUpdateVisibleItemsFrom: oldValue, to: visibleItems )
            }
        }
    }
    
    // MARK: - Public API
    
    weak var delegate: VPaginatedDataSourceDelegate?
    
    func unload() {
        visibleItems = NSOrderedSet()
        currentPaginatedRequestOperation = nil
        currentLocalOperation = nil
        pagesLoaded = Set<Int>()
        state = .Cleared
    }
    
    func cancelCurrentOperation() {
        currentPaginatedRequestOperation?.cancel()
        currentPaginatedRequestOperation = nil
        state = visibleItems.count == 0 ? .NoResults : .Results
    }
    
    /// Reloads the first page into `visibleItems` using a descendent of `FetcherOperation`, which
    /// operations locally on the persistent store only and does not send a network request.
    func refreshLocal( @noescape createOperation createOperation: () -> FetcherOperation, completion: (([AnyObject]?, NSError?) -> Void)? = nil ) {
        guard currentLocalOperation == nil else {
            return
        }
        let operation: FetcherOperation = createOperation()
        operation.queue() { (results, error) in
            
            if let error = error {
                self.delegate?.paginatedDataSource(self, didReceiveError: error)
                self.state = .Error
                
            } else if let results = results {
                self.visibleItems = self.visibleItems.v_orderedSet(byAddingObjects: results, forPageType: .Previous)
                self.state = self.visibleItems.count == 0 ? .NoResults : .Results
                self.currentLocalOperation = nil
            }
            completion?(results, error)
        }
        currentLocalOperation = operation
    }
    
    func removeDeletedItems() {
        let oldCount = visibleItems.count
        visibleItems = visibleItems.v_orderedSetFitleredForDeletedObjects()
        if oldCount > 0 && visibleItems == 0 {
            // Setting state to `NoResults` will show a no content view, so we shouldonly
            // do that if there was content previously.  Otherwise, the view could simply
            // not be finished loading yet.
            state = .NoResults
        }
    }
    
    /// Reloads the first page into `visibleItems` using a descendent of `PaginatedRequestOperation`, which
    /// operates by sending a network request to retreive results, then parses them into the persistent store.
    func refreshRemote<T: Paginated>( @noescape createOperation createOperation: () -> T, completion: (([AnyObject]?, NSError?) -> Void)? = nil ) {
        
        var operation: T = createOperation()
        guard let requestOperation = operation as? FetcherOperation else {
            return
        }
        
        state = .Loading
        requestOperation.queue() { (results, error) in
            
            if let error = error {
                self.delegate?.paginatedDataSource(self, didReceiveError: error)
                self.state = .Error
                completion?( [], error )
                
            } else {
                let results = operation.results ?? []
                operation.results = results
                let newResults = results.filter { !self.visibleItems.containsObject( $0 ) }
                if !results.isEmpty {
                    if self.shouldStashNewContent {
                        self.stashedItems = self.stashedItems.v_orderedSet(byAddingObjects: results, forPageType: .Next)
                    } else if self.maxVisibleItems > 0 {
                        let (newItems, removed) = self.visibleItems.v_orderedSetPurgedToLimit(self.maxVisibleItems)
                        if removed.count > 0 {
                            self.isPurging = true
                            self.visibleItems = newItems
                            self.isPurging = false
                        } else {
                            self.visibleItems = self.visibleItems.v_orderedSet(byAddingObjects: results, forPageType: .Next)
                        }
                    } else {
                        self.visibleItems = self.visibleItems.v_orderedSet(byAddingObjects: results, forPageType: .Next)
                    }
                }
                self.state = self.visibleItems.count == 0 ? .NoResults : .Results
                completion?( newResults, error )
            }
        }
    }
    
    func loadPage<T: Paginated where T.PaginatorType : NumericPaginator>( pageType: VPageType, @noescape createOperation: () -> T, completion: ((results: [AnyObject]?, error: NSError?) -> Void)? = nil ) {
        
        guard !isLoading() else {
            return
        }
        
        if pageType == .First {
            // Clear all from `pagesLoaded` because .First indicates a "refresh"
            pagesLoaded = Set<Int>()
        }
        
        let operationToQueue: T?
        switch pageType {
        case .First:
            operationToQueue = createOperation()
        case .Next:
            operationToQueue = (currentPaginatedRequestOperation as? T)?.next()
        case .Previous:
            operationToQueue = (currentPaginatedRequestOperation as? T)?.prev()
        }
        
        // Return early if there is no operation to queue, i.e. no work to do
        guard let requestOperation = operationToQueue as? FetcherOperation,
            var operation = operationToQueue else {
                return
        }
        
        // Return early if we've already loaded this page
        guard !pagesLoaded.contains(operation.paginator.pageNumber) else {
            return
        }
        
        // Add the page from `pagesLoaded` so it won't be loaded again
        pagesLoaded.insert(operation.paginator.pageNumber)
        
        state = .Loading
        requestOperation.queue() { (results, error) in
            
            if let error = error {
                // Remove the page from `pagesLoaded` so that it can be attempted again
                self.pagesLoaded.remove( operation.paginator.pageNumber )
                
                // Return no results
                operation.results = []
                self.delegate?.paginatedDataSource(self, didReceiveError: error)
                self.state = .Error
                
            } else {
                let results = operation.results ?? []
                self.visibleItems = self.visibleItems.v_orderedSet(byAddingObjects: results, forPageType: pageType)
                self.state = self.visibleItems.count == 0 ? .NoResults : .Results
            }
            
            completion?( results: results, error: error )
        }
        
        self.currentPaginatedRequestOperation = requestOperation
    }
}

private extension NSOrderedSet {
    
    func v_printDisplayOrder() {
        print( flatMap { $0 as? PaginatedObjectType }.map { $0.displayOrder } )
    }
    
    func v_orderedSet( byAddingObjects objects: [AnyObject], forPageType pageType: VPageType ) -> NSOrderedSet {
        let output: NSOrderedSet
        
        switch pageType {
            
        case .First: //< reset
            output = NSOrderedSet(array: objects)
            
        case .Next: //< apend
            output = NSOrderedSet(array: self.array + objects)
            
        case .Previous: //< prepend
            output = NSOrderedSet(array: objects + self.array)
        }
        
        return output.v_orderedSetFitleredForDeletedObjects()
    }
    
    func v_orderedSetPurgedToLimit(limit: Int) -> (result: NSOrderedSet, removed: NSOrderedSet) {
        guard self.count > limit else {
            return (self, NSOrderedSet())
        }
        var items = self.array
        let range = 0..<(self.count - limit)
        let removed = Array(items[range])
        items.removeRange(range)
        return (NSOrderedSet(array: items), NSOrderedSet(array: removed))
    }
    
    func v_orderedSetFitleredForDeletedObjects() -> NSOrderedSet {
        let predicate = NSPredicate() { (object, dictionary) -> Bool in
            if let managedObject = object as? NSManagedObject {
                return managedObject.hasBeenDeleted == false
            }
            return true
        }
        let results = self.filteredOrderedSetUsingPredicate( predicate )
        return results
    }
}
