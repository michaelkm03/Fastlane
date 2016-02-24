//
//  Queueable.swift
//  victorious
//
//  Created by Patrick Lynch on 11/19/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation

protocol Queueable {
    
    typealias CompletionBlockType
    
    func executeCompletionBlock(completionBlock: CompletionBlockType)
    
    func queueOn(queue: NSOperationQueue, completion: CompletionBlockType?)
    
    func queue(completion completion: CompletionBlockType?)
    
    func queue()
}

protocol Chainable {
    
    func after(dependency: NSOperation) -> Self
    
    func before(dependent: NSOperation) -> Self
    
    func rechainAfter(dependency: NSOperation) -> Self
    
    func rechainOn(queue: NSOperationQueue, after dependency: NSOperation) -> Self
}

extension Queueable where Self : NSOperation {
    
    func queue() {
        queue(completion: nil)
    }
    
    func queue(completion completion: CompletionBlockType?) {
        queueOn(defaultQueue, completion: completion)
    }
    
    func queueOn(queue: NSOperationQueue, completion: CompletionBlockType?) {
        queue.v_addOperation(self, completion: completion)
    }
}

extension NSOperation {
    
    var defaultQueue: NSOperationQueue {
        return NSOperationQueue.v_globalBackgroundQueue
    }
}

extension NSOperation: Chainable {
    
    func after(dependency: NSOperation) -> Self {
        addDependency(dependency)
        return self
    }
    
    func before(dependent: NSOperation) -> Self {
        dependent.addDependency(self)
        return self
    }
    
    func rechainOn(queue: NSOperationQueue, after dependency: NSOperation) -> Self {
        queue.v_rechainOperation(self, after: dependency)
        return self
    }
    
    func rechainAfter(dependency: NSOperation) -> Self {
        return rechainOn(defaultQueue, after: dependency)
    }
}
