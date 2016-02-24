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
    
    private(set) var state: VDataSourceState = .Cleared {
        didSet {
            if oldValue != state {
                self.delegate?.paginatedDataSource?(self, didChangeStateFrom: oldValue, to: state)
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
    
    private(set) dynamic var visibleItems = NSOrderedSet() {
        didSet {
            if oldValue != visibleItems {
                self.delegate?.paginatedDataSource( self, didUpdateVisibleItemsFrom: oldValue, to: visibleItems )
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
        self.state = self.visibleItems.count == 0 ? .NoResults : .Results
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
        self.currentLocalOperation = operation
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
    func refreshRemote<T: PaginatedRequestOperation>( @noescape createOperation createOperation: () -> T, completion: (([AnyObject]?, NSError?) -> Void)? = nil ) {
        
        guard self.currentPaginatedRequestOperation != nil else {
            return
        }
        
        var operation: T = createOperation()
        guard let requestOperation = operation as? FetcherOperation else {
            return
        }
        
        self.state = .Loading
        requestOperation.queue() { (results, error) in
            
            if let error = error {
                self.delegate?.paginatedDataSource(self, didReceiveError: error)
                self.state = .Error
                completion?( [], error )
            
            } else {
                let results = operation.results ?? []
                operation.results = results
                let newResults = results.filter { !self.visibleItems.containsObject( $0 ) }
                if !results.isEmpty && (self.visibleItems.count == 0 || (self.visibleItems[0] as? NSObject) != (results[0] as? NSObject) ) {
                    self.visibleItems = self.visibleItems.v_orderedSet(byAddingObjects: results, forPageType: .Next)
                }
                self.state = self.visibleItems.count == 0 ? .NoResults : .Results
                completion?( newResults, error )
            }
        }
    }
    
    func loadPage<T: PaginatedRequestOperation where T.PaginatedRequestType.PaginatorType : NumericPaginator>( pageType: VPageType, @noescape createOperation: () -> T, completion: ((results: [AnyObject]?, error: NSError?) -> Void)? = nil ) {
        
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
        guard !pagesLoaded.contains(operation.request.paginator.pageNumber) else {
            return
        }
        
        // Add the page from `pagesLoaded` so it won't be loaded again
        pagesLoaded.insert(operation.request.paginator.pageNumber)
        
        self.state = .Loading
        requestOperation.queue() { (results, error) in
            
            if let error = error {
                // Remove the page from `pagesLoaded` so that it can be attempted again
                self.pagesLoaded.remove( operation.request.paginator.pageNumber )
                
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
