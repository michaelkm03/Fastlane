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
@objc open class PaginatedDataSource: NSObject, PaginatedDataSourceType {
    
    private(set) var currentPaginatedOperation: Operation?
    
    private(set) var state: VDataSourceState = .cleared {
        didSet {
            if oldValue != state {
                self.delegate?.paginatedDataSource?(self, didChangeStateFrom: oldValue, to: state)
            }
        }
    }
    
    func startStashingNewItems() {
        shouldStashNewItems = true
    }
    
    var sortOrder: ComparisonResult = .orderedAscending
    
    private var isPurging = false
    
    func unstashAll() {
        shouldStashNewItems = false
        visibleItems = visibleItems.v_orderedSet(byAddingObjects: stashedItems.array as [AnyObject])
        purgedStashedCount = 0
        stashedItems = NSOrderedSet()
    }
    
    var isStashingNewItems: Bool {
        return shouldStashNewItems
    }
    private var shouldStashNewItems: Bool = false
    
    var shouldShowNextPageActivity: Bool {
        return state == .loading && visibleItems.count > 0
    }
    
    // Tracks page numbers already loaded to prevent re-loading pages unecessarily
    private var pagesLoaded = Set<Int>()
    
    func isLoading() -> Bool {
        return state == .loading
    }
    
    func purgeOlderItems(limit: Int) {
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
        state = .cleared
    }
    
    func cancelCurrentOperation() {
        currentPaginatedOperation?.cancel()
        currentPaginatedOperation = nil
    }
    
    func removeDeletedItems() {
        let oldCount = self.visibleItems.count
        self.visibleItems = self.visibleItems.v_orderedSetFitleredForDeletedObjects()
        if oldCount > 0 && self.visibleItems.count == 0 {
            // Setting state to `noResults` will show a no content view, so we shouldonly
            // do that if there was content previously.  Otherwise, the view could simply
            // not be finished loading yet.
            self.state = .noResults
        }
    }
    
    func loadPage<Operation: Paginated>(_ pageType: VPageType, createOperation: () -> Operation, completion: ((_ results: [AnyObject]?, _ error: NSError?, _ cancelled: Bool) -> Void)? = nil) where Operation.PaginatorType: NumericPaginator {
        guard !isLoading() else {
            return
        }
        
        if pageType == .first {
            // Clear all from `pagesLoaded` because .First indicates a "refresh"
            pagesLoaded = Set<Int>()
        }
        
        // Return early if there is no operation to queue, i.e. no work to do
        guard let operation: Operation = {
            switch pageType {
                case .first: return createOperation()
                case .next: return (currentPaginatedOperation as? Operation)?.next()
                case .previous: return (currentPaginatedOperation as? Operation)?.prev()
            }
        }() else {
            return
        }
        
        // Return early if we've already loaded this page
        guard !pagesLoaded.contains(operation.paginator.pageNumber) else {
            return
        }
        
        // Add the page from `pagesLoaded` so it won't be loaded again
        pagesLoaded.insert(operation.paginator.pageNumber)
        
        state = .loading
        
        // We need to cast to AsyncOperation<[AnyObject]> here to call queue because we need a concrete operation type
        // that defines its result type.
        (operation as? AsyncOperation<[AnyObject]>)?.queue { [weak self] result in
            guard let strongSelf = self else {
                return
            }
            
            switch result {
                case .success(let results):
                    if results.isEmpty {
                        // Nothing to do here.
                    } else {
                        // No conformance to `PaginatedObjectType` in the results, add according to `pageType`
                        strongSelf.visibleItems = strongSelf.visibleItems.v_orderedSet(
                            byAddingObjects: results,
                            forPageType: pageType
                        )
                    }
                    
                    strongSelf.state = strongSelf.visibleItems.count == 0 ? .noResults : .results
                    
                    completion?(results, nil, false)
                
                case .failure(let error):
                    // Remove the page from `pagesLoaded` so that it can be attempted again
                    strongSelf.pagesLoaded.remove(operation.paginator.pageNumber)
                    
                    // Return no results
                    strongSelf.delegate?.paginatedDataSource(strongSelf, didReceiveError: error as NSError)
                    strongSelf.state = .error
                    
                    completion?(nil, error as NSError, false)
                
                case .cancelled:
                    // Remove the page from `pagesLoaded` so that it can be attempted again
                    strongSelf.pagesLoaded.remove(operation.paginator.pageNumber)
                    strongSelf.state = strongSelf.visibleItems.count == 0 ? .noResults : .results
                    
                    completion?(nil, nil, true)
            }
        }
        
        currentPaginatedOperation = operation as? Foundation.Operation
    }
}

private extension NSOrderedSet {
    
    func v_orderedSetFitleredForDeletedObjects() -> NSOrderedSet {
        let predicate = NSPredicate { object, dictionary in
            return true
        }
        return filtered(using: predicate)
    }
    
    func v_orderedSet( byAddingObjects objects: [AnyObject], forPageType pageType: VPageType ) -> NSOrderedSet {
        let output: NSOrderedSet
        
        switch pageType {
            case .first: //< reset
                output = NSOrderedSet(array: objects)
                
            case .next: //< append
                output = NSOrderedSet(array: self.array + objects)
                
            case .previous: //< prepend
                output = NSOrderedSet(array: objects + self.array)
        }
        
        return output.v_orderedSetFitleredForDeletedObjects()
    }
    
    func v_orderedSet(byAddingObjects objects: [AnyObject]) -> NSOrderedSet {
        return NSOrderedSet(array: self.array + objects)
    }
    
    func v_orderedSetPurgedBy(_ limit: Int) -> NSOrderedSet {
        let rangeStart = Swift.max(0, count - limit)
        let rangeEnd = count
        let remaining = Array(array[rangeStart..<rangeEnd])
        return NSOrderedSet(array: remaining)
    }
}
