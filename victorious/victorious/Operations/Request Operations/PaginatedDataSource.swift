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
        case .Refresh, .CheckNew:
            operationToQueue = createOperation()
        case .Next:
            operationToQueue = (currentOperation as? T)?.next()
        case .Previous:
            operationToQueue = (currentOperation as? T)?.prev()
        }
        
        guard let requestOperation = operationToQueue as? RequestOperation,
            var operation = operationToQueue else {
                return
        }
        
        self.state = .Loading
        
        if pageType == .Refresh && hasNetworkConnection {
            // TODO: This would be ideal after the request succeeeds but before parsing begins
            operation.clearResults()
        }
        
        requestOperation.queue() { error in
            
            if let error = error {
                
                // Fetch local results if we failed because of no network
                if error.code == RequestOperation.errorCodeNoNetworkConnection {
                   operation.results = operation.fetchResults()
                    
                } else {
                    // Otherwise, return no results
                    operation.results = []
                }
                self.onOperationComplete(operation, pageType: pageType)
                self.state = .Error
          
            } else {
                operation.results = operation.fetchResults()
                self.onOperationComplete(operation, pageType: pageType)
                self.state = self.visibleItems.count == 0 ? .NoResults : .Results
            }
            
            completion?( operation: operation, error: error )
        }
        
        self.currentOperation = requestOperation
    }
    
    // MARK: - Private helpers
    
    private func onOperationComplete<T: PaginatedOperation>( operation: T, pageType: VPageType) {
        guard let results = operation.results where !results.isEmpty else {
            return
        }
        self.visibleItems = self.visibleItems.v_orderedSet(byAddingObjects: results, forPageType: pageType)
    }
}

private extension NSOrderedSet {
    
    func v_orderedSet( byAddingObjects objects: [AnyObject], forPageType pageType: VPageType ) -> NSOrderedSet {
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
