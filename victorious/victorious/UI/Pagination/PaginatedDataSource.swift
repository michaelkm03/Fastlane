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
    private(set) weak var currentPaginatedOperation: NSOperation?
    
    private(set) var state: VDataSourceState = .Cleared {
        didSet {
            if oldValue != state {
                self.delegate?.paginatedDataSource?(self, didChangeStateFrom: oldValue, to: state)
            }
        }
    }
    
    func startStashingNewItems() {
        shouldStashNewItems = true
    }
    
    var sortOrder: NSComparisonResult = .OrderedAscending
    
    private var isPurging = false
    
    func unstashAll() {
        shouldStashNewItems = false
        visibleItems = visibleItems.v_orderedSet(byAddingObjects: stashedItems.array, sortOrder: self.sortOrder)
        purgedStashedCount = 0
        stashedItems = NSOrderedSet()
    }
    
    var isStashingNewItems: Bool {
        return shouldStashNewItems
    }
    private var shouldStashNewItems: Bool = false
    
    var shouldShowNextPageActivity: Bool {
        return state == .Loading && visibleItems.count > 0
    }
    
    // Tracks page numbers already loaded to prevent re-loading pages unecessarily
    private var pagesLoaded = Set<Int>()
    
    func isLoading() -> Bool {
        return state == .Loading
    }
    
    func purgeOlderItems(limit limit: Int) {
        if visibleItems.count > limit {
            isPurging = true
            visibleItems = visibleItems.v_orderedSetPurgedBy(limit)
            isPurging = false
        }
    }
    
    private var purgedStashedCount = 0
    
    var stashedItemsCount: Int {
        return stashedItems.count + purgedStashedCount
    }
    
    private var _stashedItems = NSOrderedSet()
    
    private var stashedItems: NSOrderedSet {
        set {
            let oldValue = _stashedItems
            let shouldUpdateDelegate = _stashedItems.count != newValue.count
            let maxStashedItems = 5
            if newValue.count > maxStashedItems {
                purgedStashedCount += newValue.count - maxStashedItems
                _stashedItems = _stashedItems.v_orderedSetPurgedBy(maxStashedItems)
            } else {
                _stashedItems = newValue
            }
            if shouldUpdateDelegate {
                delegate?.paginatedDataSource?( self, didUpdateStashedItemsFrom: oldValue, to: newValue )
            }
        }
        get {
            return _stashedItems
        }
    }
    
    private(set) var visibleItems = NSOrderedSet() {
        didSet {
            if oldValue != visibleItems {
                if isPurging {
                    delegate?.paginatedDataSource?( self, didPurgeVisibleItemsFrom: oldValue, to: visibleItems )
                } else {
                    delegate?.paginatedDataSource( self, didUpdateVisibleItemsFrom: oldValue, to: visibleItems )
                }
            }
        }
    }
    
    // MARK: - Public API
    
    weak var delegate: VPaginatedDataSourceDelegate?
    
    func unload() {
        visibleItems = NSOrderedSet()
        currentPaginatedOperation = nil
        pagesLoaded = Set<Int>()
        state = .Cleared
    }
    
    func cancelCurrentOperation() {
        currentPaginatedOperation?.cancel()
        currentPaginatedOperation = nil
    }
    
    func removeDeletedItems() {
        let oldCount = self.visibleItems.count
        self.visibleItems = self.visibleItems.v_orderedSetFitleredForDeletedObjects()
        if oldCount > 0 && self.visibleItems == 0 {
            // Setting state to `NoResults` will show a no content view, so we shouldonly
            // do that if there was content previously.  Otherwise, the view could simply
            // not be finished loading yet.
            self.state = .NoResults
        }
    }
    
    /// Reloads the first page into `visibleItems` using a descendent of `PaginatedRequestOperation`, which
    /// operates by sending a network request to retreive results, then parses them into the persistent store.
    func loadNewItems( @noescape createOperation createOperation: () -> FetcherOperation, completion: (([AnyObject]?, NSError?, Bool) -> Void)?) {
        
        let operation: FetcherOperation = createOperation()
        
        self.state = .Loading
        operation.queue() { results, error, cancelled in
            
            if let error = error {
                self.delegate?.paginatedDataSource(self, didReceiveError: error)
                self.state = .Error
                completion?( [], error, cancelled )
                
            } else {
                let results = operation.results ?? []
                let newResults = results.filter { !self.visibleItems.containsObject( $0 ) }
                if self.shouldStashNewItems {
                    self.stashedItems = self.stashedItems.v_orderedSet(byAddingObjects: newResults, sortOrder: self.sortOrder)
                } else {
                    self.visibleItems = self.visibleItems.v_orderedSet(byAddingObjects: newResults, sortOrder: self.sortOrder)
                }
                self.state = self.visibleItems.count == 0 ? .NoResults : .Results
                completion?( newResults, error, cancelled )
            }
        }
    }
    
    func loadPage<T: Paginated where T.PaginatorType : NumericPaginator>( pageType: VPageType, @noescape createOperation: () -> T, completion: ((results: [AnyObject]?, error: NSError?, cancelled: Bool) -> Void)? = nil ) {
        
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
            operationToQueue = (currentPaginatedOperation as? T)?.next()
        case .Previous:
            operationToQueue = (currentPaginatedOperation as? T)?.prev()
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
        
        self.state = .Loading
        requestOperation.queue() { results, error, cancelled in
            
            if cancelled {
                // Remove the page from `pagesLoaded` so that it can be attempted again
                self.pagesLoaded.remove( operation.paginator.pageNumber )
                self.state = self.visibleItems.count == 0 ? .NoResults : .Results
                
            } else if let error = error {
                // Remove the page from `pagesLoaded` so that it can be attempted again
                self.pagesLoaded.remove( operation.paginator.pageNumber )
                
                // Return no results
                self.delegate?.paginatedDataSource(self, didReceiveError: error)
                self.state = .Error
                
            } else {
                let results = operation.results ?? []
                self.visibleItems = self.visibleItems.v_orderedSet(byAddingObjects: results, sortOrder: self.sortOrder)
                self.state = self.visibleItems.count == 0 ? .NoResults : .Results
            }
            
            completion?( results: results, error: error, cancelled: cancelled )
        }
        
        self.currentPaginatedOperation = requestOperation
    }
}

private extension NSOrderedSet {
    
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
    
    func v_orderedSet( byAddingObjects objects: [AnyObject], sortOrder: NSComparisonResult) -> NSOrderedSet {
        let combinedArray = self.array + objects
        let paginatedObjects = combinedArray.flatMap { $0 as? PaginatedObjectType }
        if paginatedObjects.isEmpty {
            // If we don't have `PaginatedObjectType`, we fall back to the "append to next page" strategy
            return NSOrderedSet(array: combinedArray)
        } else {
            // If we have instances of `PaginatedObjectType` we can sort directly on `displayOrder`.
            let sortedArray = paginatedObjects.sort { $0.displayOrder.compare($1.displayOrder) == sortOrder }
            return NSOrderedSet(array: sortedArray)
        }
    }
    
    func v_orderedSetPurgedBy(limit: Int) -> NSOrderedSet {
        let rangeStart = max(0, count - limit)
        let rangeEnd = count
        let remaining = Array(array[rangeStart..<rangeEnd])
        return NSOrderedSet(array: remaining)
    }
}
