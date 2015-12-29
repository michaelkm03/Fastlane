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
    var backgroundContext: NSManagedObjectContext { get }
    
    /// Deletes the file on disk at the persistent store URL
    /// DANGER: This will irrevocably delete all local data!
    @objc(deletePersistentStoreAndReturnError:) func deletePersistentStore() throws
}
