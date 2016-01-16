//
//  PaginatedDataSource.swift
//  victorious
//
//  Created by Patrick Lynch on 12/19/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation

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
    }
    
    func cancelCurrentOperation() {
        currentOperation?.cancel()
        currentOperation = nil
    }
    
    private var hasNetworkConnection: Bool {
        return VReachability.reachabilityForInternetConnection().currentReachabilityStatus() != .NotReachable
    }
    
    func loadPage<T: PaginatedOperation>( pageType: VPageType, @noescape createOperation: () -> T, completion: ((operation: T?, error: NSError?) -> Void)? = nil ) {
        
        guard state != .Loading else { return }
        
        let operationToQueue: T?
        switch pageType {
        case .Refresh:
            operationToQueue = createOperation()
        case .Next:
            operationToQueue = (currentOperation as? T)?.next()
        case .Previous:
            operationToQueue = (currentOperation as? T)?.prev()
        case .CheckNew:
            let operation = createOperation()
            let results = operation.fetchResults() ?? []
            self.visibleItems = self.visibleItems.v_orderedSet(byAddingObjects: results, forPageType: pageType)
            operationToQueue = nil
            return
        }
        
        guard let requestOperation = operationToQueue as? RequestOperation,
            var operation = operationToQueue else {
                return
        }
        
        self.state = .Loading
        
        // Load any local results immeidately
        if pageType == .Refresh {
            let results = operation.fetchResults() ?? []
            self.visibleItems = self.visibleItems.v_orderedSet(byAddingObjects: results, forPageType: pageType)
        }
        
        requestOperation.queue() { error in
            
            if let error = error {
                // Fetch local results if we failed because of no network
                if error.code == RequestOperation.errorCodeNoNetworkConnection && pageType != .Refresh {
                    operation.results = operation.fetchResults()
                    let results = operation.results ?? []
                    self.visibleItems = self.visibleItems.v_orderedSet(byAddingObjects: results, forPageType: pageType)
                    
                } else {
                    // Otherwise, return no results
                    operation.results = []
                    self.state = .Error
                }
          
            } else {
                operation.results = operation.fetchResults()
                let results = operation.results ?? []
                self.visibleItems = self.visibleItems.v_orderedSet(byAddingObjects: results, forPageType: pageType)
                self.state = self.visibleItems.count == 0 ? .NoResults : .Results
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
            
        case .Refresh: //< reset
            return NSOrderedSet(array: objects)
            
        case .Next: //< apend
            return NSOrderedSet(array: self.array + objects)
            
        case .Previous, .CheckNew: //< prepend
            return NSOrderedSet(array: objects + self.array)
        }
    }
}
