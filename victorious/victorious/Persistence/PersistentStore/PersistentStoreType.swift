//
//  PersistentStoreType.swift
//  victorious
//
//  Created by Patrick Lynch on 11/5/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation

enum PersistentStoreError: ErrorType {
    case DeleteFailed(storeURL: NSURL, error: ErrorType)
}

/// Defines an object that provides access to a persistent backed by CoreData that exposes
/// its internally configured and managed instances of `NSManagedObjectContext` which are the
/// primary interfaces through which application code should interact.
@objc protocol PersistentStoreType {
    
    /// A context used primarily for reads that should only ever be accessed from the main queue.
    /// To ensure this, always call `performBlock(_:)` or `performBlockAndWait(_:)` when interacting
    /// with this context.
    var mainContext: NSManagedObjectContext { get }
    
    /// A context used primarily for asynchronous writes that should only ever be accessed from
    /// the propery queue by calling `performBlock(_:)` or `performBlockAndWait(_:)` when interacting
    /// with this context.
    func createBackgroundContext() -> NSManagedObjectContext
}

/// An object that provides functions for finding an appropriate concrete implementation
/// of `PersistentStoreType` for using in unit tests and application code.
class PersistentStoreSelector: NSObject {
    
    /// Returns the primary persistent store used by this application and appropriate for its
    /// environment.
    class var defaultPersistentStore: PersistentStoreType {
        
        if NSBundle.v_isTestBundle {
            return TestPersistentStore()
        } else {
            return MainPersistentStore()
        }
    }
}
