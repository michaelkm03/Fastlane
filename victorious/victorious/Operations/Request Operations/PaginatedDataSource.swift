//
//  PaginatedDataSource.swift
//  victorious
//
//  Created by Patrick Lynch on 12/19/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

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
    
    // Keeps a reference without retaining; avoids needing [weak self] when queueing
    private(set) weak var currentOperation: NSOperation?
    
    private(set) var state: DataSourceState = .Cleared {
        didSet {
            if oldValue != state {
                self.delegate?.paginatedDataSource?(self, didChangeStateFrom: oldValue, to: state)
            }
        }
    }
    
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
        cancelCurrentOperation()
        visibleItems = NSOrderedSet()
        pagesLoaded = Set<Int>()
    }
    
    func cancelCurrentOperation() {
        currentOperation?.cancel()
        currentOperation = nil
        self.state = self.visibleItems.count == 0 ? .NoResults : .Results
    }
    
    func refreshLocal( @noescape createOperation createOperation: () -> FetcherOperation, completion: (([AnyObject]) -> Void)? = nil ) {
        let operation: FetcherOperation = createOperation()
        operation.queue() { results in
            self.visibleItems = self.visibleItems.v_orderedSet(byAddingObjects: results, forPageType: .Previous)
            self.state = self.visibleItems.count == 0 ? .NoResults : .Results
            completion?(results)
        }
    }
    
    func refreshRemote<T: PaginatedOperation>( @noescape createOperation createOperation: () -> T, completion: (([AnyObject], NSError?) -> Void)? = nil ) {
        
        guard self.currentOperation != nil else {
            return
        }
        
        var operation: T = createOperation()
        guard let requestOperation = operation as? RequestOperation else {
            return
        }
        
        self.state = .Loading
        requestOperation.queue() { error in
            
            let results = operation.fetchResults() ?? []
            operation.results = results
            if !results.isEmpty && (self.visibleItems.count == 0 || (self.visibleItems[0] as? NSObject) != (results[0] as? NSObject) ) {
                self.visibleItems = self.visibleItems.v_orderedSet(byAddingObjects: results, forPageType: .First)
            }
            self.state = self.visibleItems.count == 0 ? .NoResults : .Results
            
            // TODO: Only send back results that are new, not eveyrthing in `visibleItems`
            completion?( operation.results ?? [], error )
        }
    }
    
    func loadPage<T: PaginatedOperation where T.PaginatedRequestType.PaginatorType : NumericPaginator>( pageType: VPageType, @noescape createOperation: () -> T, completion: ((operation: T?, error: NSError?) -> Void)? = nil ) {
        
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
            operationToQueue = (currentOperation as? T)?.next()
        case .Previous:
            operationToQueue = (currentOperation as? T)?.prev()
        }
        
        // Return early if there is no operation to queue, i.e. no work to do
        guard let requestOperation = operationToQueue as? RequestOperation,
            var operation = operationToQueue where !pagesLoaded.contains(operation.request.paginator.pageNumber) else {
                return
        }
        
        // Add the page from `pagesLoaded` so it won't be loaded again
        pagesLoaded.insert(operation.request.paginator.pageNumber)
        
        self.state = .Loading
        requestOperation.queue() { error in
            
            // Fetch local results if we failed because of no network
            if error == nil || (error?.code == RequestOperation.errorCodeNoNetworkConnection && pageType != .First) {
                let results = operation.fetchResults() ?? []
                operation.results = results
                self.visibleItems = self.visibleItems.v_orderedSet(byAddingObjects: results, forPageType: pageType)
                self.state = self.visibleItems.count == 0 ? .NoResults : .Results
                
            } else {
                // Remove the page from `pagesLoaded` so that it can be attempted again
                self.pagesLoaded.remove( operation.request.paginator.pageNumber )
                
                // Return no results
                operation.results = []
                self.state = .Error
            }
            
            completion?( operation: operation, error: error )
        }
        
        self.currentOperation = requestOperation
    }
}

private extension NSOrderedSet {
    
    func v_orderedSet( byAddingObjects objects: [AnyObject], forPageType pageType: VPageType ) -> NSOrderedSet {
        guard !objects.isEmpty else {
            return self.copy() as! NSOrderedSet
        }
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
