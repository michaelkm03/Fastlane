//
//  PaginatedDataSource.swift
//  victorious
//
//  Created by Patrick Lynch on 12/19/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation

@objc class PaginatedDataSource: NSObject {
    
    private(set) var currentOperation: RequestOperation?
    private(set) var isLoading: Bool = false
    
    private(set) var filteredItems = NSOrderedSet()
    
    private(set) var unfilteredItems = NSOrderedSet() {
        didSet {
            applyFilters()
        }
    }
    
    private typealias Filter = AnyObject -> Bool
    
    private var filters = [Filter]()
    
    var visibleItems: NSOrderedSet {
        return filteredItems
    }
    
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
        filteredItems = NSOrderedSet()
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
            operationToQueue = (self.currentOperation as? T)?.next() as? RequestOperation
        case .Previous:
            operationToQueue = (self.currentOperation as? T)?.prev() as? RequestOperation
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
        var items = self.unfilteredItems.array
        for filter in self.filters {
            items = items.filter { filter($0) }
        }
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
