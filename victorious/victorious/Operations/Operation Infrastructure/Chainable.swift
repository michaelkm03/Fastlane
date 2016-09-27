//
//  Chainable.swift
//  victorious
//
//  Created by Jarod Long on 9/8/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

/// Defines an object that offers a little twist on NSOperation's dependency API
/// with the purpose of composing operations into linear chain structures instead of
/// a branched tree structure.
protocol Chainable {
    /// Add the provided operation as a dependency to the receiver, i.e. the receiver
    /// becomes dependent and will not execute until the operation is finished.  Returns
    /// itself so that the operation can be modified or queued immediately after:
    /// `operationB.after(operationB).queue()`
    func after(_ dependency: Operation) -> Self
    
    /// Add the receiver as a dependency to the provided operation, i.e. the operation
    /// becomes dependent and will not execute until the receiver is finished.
    /// Returns itself so that the operation can be modified or queued immediately after:
    /// `operationA.before(operationB).queue()`
    func before(_ dependent: Operation) -> Self
    
    /// Add the provided operation as a dependency to the receiver, i.e. the operation
    /// becomes dependent and will not execute until the receiver is finished.  The receiver
    /// also takes on the completion block and any dependent operations in operation's
    /// `v_defaultQueue`, essentially "rechaining" the order of execution.
    func rechainAfter(_ dependency: Operation) -> Self
}

extension Operation: Chainable {
    func after(_ dependency: Operation) -> Self {
        addDependency(dependency)
        return self
    }
    
    func before(_ dependent: Operation) -> Self {
        dependent.addDependency(self)
        return self
    }
    
    func rechainAfter(_ dependency: Operation) -> Self {
        addDependency(dependency)
        
        // Rechain (transfer) dependencies
        for dependent in dependency.dependentOperations {
            dependent.addDependency(self)
        }
        
        return self
    }
}
