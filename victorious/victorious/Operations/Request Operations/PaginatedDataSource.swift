//
//  PaginatedDataSource.swift
//  victorious
//
//  Created by Patrick Lynch on 12/19/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

/// A utility that abstracts the interaction between UI code and paginated `RequestOperation`s
/// into an API that is more concise and reuable between any paginated view controllers that have
/// a simple collection or table view layout.
@objc public class PaginatedDataSource: NSObject, PaginatedDataSourceType, GenericPaginatedDataSourceType {
    
    // Keeps a reference without retaining; avoids needing [weak self] when queueing
    private(set) weak var currentPaginatedOperation: NSOperation?
    private(set) weak var currentLocalOperation: NSOperation?
    
    private(set) var hasLoadedLastPage: Bool = false
    
    private(set) var state: DataSourceState = .Cleared {
        didSet {
            if oldValue != state {
                self.delegate?.paginatedDataSource?(self, didChangeStateFrom: oldValue, to: state)
            }
        }
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
    
    var delegate: PaginatedDataSourceDelegate?
    
    func unload() {
        visibleItems = NSOrderedSet()
        pagesLoaded = Set<Int>()
        state = .Cleared
    }
    
    func cancelCurrentOperation() {
        currentPaginatedOperation?.cancel()
        currentPaginatedOperation = nil
        self.state = self.visibleItems.count == 0 ? .NoResults : .Results
    }
    
    /// Reloads the first page into `visibleItems` using a descendent of `FetcherOperation`, which
    /// operations locally on the persistent store only and does not send a network request.
    func refreshLocal( @noescape createOperation createOperation: () -> FetcherOperation, completion: (([AnyObject]) -> Void)? = nil ) {
        guard currentLocalOperation == nil else {
            return
        }
        let operation: FetcherOperation = createOperation()
        operation.queue() { results in
            for obj in results {
                if (obj as? NSManagedObject)?.managedObjectContext == nil {
                    print( "FOUND ONE" )
                }
            }
            self.visibleItems = self.visibleItems.v_orderedSet(byAddingObjects: results, forPageType: .Previous)
            //self.visibleItems =  self.filterFlaggedForDeletionItemsFromResults(results)
            self.state = self.visibleItems.count == 0 ? .NoResults : .Results
            self.currentLocalOperation = nil
            completion?(results)
        }
        self.currentLocalOperation = operation
    }
    
    func refreshLocalJustFilters() {
        //self.visibleItems = self.filterFlaggedForDeletionItemsFromResults(self.visibleItems.array)
    }
    
    /// Reloads the first page into `visibleItems` using a descendent of `PaginatedOperation`, which
    /// operates by sending a network request to retreive results, then parses them into the persistent store.
    func refreshRemote<T: PaginatedOperation>( @noescape createOperation createOperation: () -> T, completion: (([AnyObject], NSError?) -> Void)? = nil ) {
        
        guard self.currentPaginatedOperation != nil else {
            return
        }
        
        var operation: T = createOperation()
        guard let requestOperation = operation as? RequestOperation else {
            return
        }
        
        self.state = .Loading
        requestOperation.queue() { error in
            
            let results = operation.results ?? []
            operation.results = results
            let newResults = results.filter { !self.visibleItems.containsObject( $0 ) }
            if !results.isEmpty && (self.visibleItems.count == 0 || (self.visibleItems[0] as? NSObject) != (results[0] as? NSObject) ) {
                self.visibleItems = self.visibleItems.v_orderedSet(byAddingObjects: results, forPageType: .First)
            }
            self.state = self.visibleItems.count == 0 ? .NoResults : .Results
            completion?( newResults, error )
        }
    }
    
    func loadPage<T: PaginatedOperation where T.PaginatedRequestType.PaginatorType : NumericPaginator>( pageType: VPageType, @noescape createOperation: () -> T, completion: ((operation: T?, error: NSError?) -> Void)? = nil ) {
        
        guard !isLoading() else {
            return
        }
        
        if pageType == .Next {
            guard !self.hasLoadedLastPage else {
                return
            }
        }
        
        if pageType == .First {
            // Clear all from `pagesLoaded` because .First indicates a "refresh"
            pagesLoaded = Set<Int>()
            self.hasLoadedLastPage = false
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
        guard let requestOperation = operationToQueue as? RequestOperation,
            var operation = operationToQueue else {
                self.hasLoadedLastPage = true
                return
        }
        
        // Return early if we've already loaded this page
        guard !pagesLoaded.contains(operation.request.paginator.pageNumber) else {
            return
        }
        
        // Add the page from `pagesLoaded` so it won't be loaded again
        pagesLoaded.insert(operation.request.paginator.pageNumber)
        
        self.state = .Loading
        requestOperation.queue() { error in
            
            // Fetch local results if we failed because of no network
            if error == nil {
                let results = operation.results ?? []
                self.hasLoadedLastPage = results.isEmpty
                self.visibleItems = self.visibleItems.v_orderedSet(byAddingObjects: results, forPageType: pageType)
                self.state = self.visibleItems.count == 0 ? .NoResults : .Results
                
            } else {
                // Remove the page from `pagesLoaded` so that it can be attempted again
                self.pagesLoaded.remove( operation.request.paginator.pageNumber )
                
                // Return no results
                operation.results = []
                self.hasLoadedLastPage = true
                self.state = .Error
            }
            
            completion?( operation: operation, error: error )
        }
        
        self.currentPaginatedOperation = requestOperation
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
        
        let predicate = NSPredicate(format: "hasBeenDeleted == YES")
        return output.filteredOrderedSetUsingPredicate( predicate )
    }
}
