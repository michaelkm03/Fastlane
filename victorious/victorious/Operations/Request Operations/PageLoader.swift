//
//  PageLoader.swift
//  victorious
//
//  Created by Patrick Lynch on 12/19/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation

class PageLoader<T: PaginatedOperation> {
    
    private (set) var currentOperation: RequestOperation?
    private (set) var isLoading: Bool = false
    
    func loadPage( pageType: VPageType, createOperation:Void -> RequestOperation, completion: (operation: T, error: NSError?) -> Void ) {
        guard !isLoading else {
            return
        }
        
        let operationToQueue: RequestOperation?
        switch pageType {
        case .First:
            operationToQueue = createOperation()
        case .Next:
            operationToQueue = (self.currentOperation as? T)?.next() as? RequestOperation
        case .Previous:
            operationToQueue = (self.currentOperation as? T)?.prev() as? RequestOperation
        }
        
        if let operation = operationToQueue {
            self.isLoading = true
            operation.queue() { error in
                self.isLoading = false
                completion( operation: operation as! T, error: error )
            }
        }
    }
}

@objc class VPageLoaderObjC: NSObject {
    
    func loadPage( pageType: VPageType, createOperation:Void -> RequestOperation, completion: (operation: RequestOperation, error: NSError?) -> Void ) {
        
    }
}