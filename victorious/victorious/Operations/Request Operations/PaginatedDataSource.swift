//
//  PaginatedDataSource.swift
//  victorious
//
//  Created by Patrick Lynch on 12/19/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation

@objc protocol PaginatedDataSourceDelegate {
    func paginatedDataSource( paginatedDataSource: PaginatedDataSource, didUpdateVisibleItemsFrom oldValue: NSOrderedSet, to newValue: NSOrderedSet)
}

@objc class PaginatedDataSource: NSObject {
    
    private(set) var currentOperation: RequestOperation?
    private(set) var isLoading: Bool = false
    
    var delegate: PaginatedDataSourceDelegate?
    
    private(set) dynamic var visibleItems = NSOrderedSet() {
        didSet {
            self.delegate?.paginatedDataSource( self, didUpdateVisibleItemsFrom: oldValue, to: visibleItems )
        }
    }
    
    private(set) var unfilteredItems = NSOrderedSet() {
        didSet {
            applyFilters()
        }
    }
    
    private typealias Filter = AnyObject -> Bool
    
    private var filters = [Filter]()
    
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
        
        if let operation = operationToQueue,
            typedOperation = operationToQueue as? T {
                self.currentOperation = operation
                self.isLoading = true
                operation.queue() { error in
                    self.isLoading = false
                    
                    if let results = (operation as? ResultsOperation)?.results where results.count > 0 {
                        self.unfilteredItems = self.unfilteredItems.v_orderedSet( results, pageType: pageType)
                    }
                    completion?( operation: typedOperation, error: error )
                }
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
    
    func v_orderedSet( objects: [AnyObject], pageType: VPageType ) -> NSOrderedSet {
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
