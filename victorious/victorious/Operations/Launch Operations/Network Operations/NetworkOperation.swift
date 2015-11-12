//
//  NetworkOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 11/11/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation

@objc class NetworkOperation: Operation {
    
    private static let queue = NSOperationQueue()
    
    class func sharedQueue() -> NSOperationQueue {
        return NetworkOperation.queue
    }
    
    func queueInBackground() {
        self.queueInBackground(nil)
    }
    
    func queueInBackground( completionMainQueueBlock:((NSError?)->())?) {
        self.completionBlock = {
            dispatch_async( dispatch_get_main_queue()) {
                self.onComplete()
                completionMainQueueBlock?( self.error )
            }
        }
        NetworkOperation.queue.addOperation( self )
    }
    
    func queueNext( operation: NetworkOperation ) {
        for dependentOperation in dependencyOperations {
            dependentOperation.addDependency( operation )
        }
        operation.queueInBackground()
    }
    
    var dependencyOperations: [NSOperation] {
        return NetworkOperation.queue.operations.filter { $0.dependencies.contains(self) }
    }
    
    func cancelAllOperations() {
        for operation in NetworkOperation.queue.operations {
            operation.cancel()
        }
    }
    
    private var error: NSError?
    
    func onComplete() {
        // Override in subclasses
    }
    
    func onError( error: NSError? ) {
        // Override in subclasses
    }
}
