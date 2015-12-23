//
//  NSManagedObjectContext+Perform.swift
//  victorious
//
//  Created by Patrick Lynch on 12/17/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import CoreData

extension NSManagedObjectContext {
    
    /// An extension of `performBlock(_:)` that includes the receiver as the first argument in the block.
    /// Executes asynchronously on the receiver's appropriate queue.
    func v_performBlock(block: NSManagedObjectContext -> Void) {
        performBlock() {
            block(self)
        }
    }
    
    /// An extension of `v_performBlockAndWait(_:)` that includes the receiver as the first argument in the block.
    /// Executes synchronously on the receiver's appropriate queue.
    func v_performBlockAndWait<T>(block: NSManagedObjectContext -> T) -> T {
        var result: T?
        performBlockAndWait() {
            result = block(self)
        }
        return result!
    }
}
