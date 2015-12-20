//
//  PageLoader.swift
//  victorious
//
//  Created by Patrick Lynch on 12/19/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation

@objc class PageLoader: NSObject {
    
    private(set) var currentOperation: RequestOperation?
    
    private(set) var isLoading: Bool = false
    
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
                    completion?( operation: typedOperation, error: error )
                }
        }
    }
}
