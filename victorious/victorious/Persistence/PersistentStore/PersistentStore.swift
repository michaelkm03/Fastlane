//
//  Persistence.swift
//  victorious
//
//  Created by Patrick Lynch on 11/5/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK


/// An object that provides access to this application's primary peristent store.
/// It has an internally configured a singleton object that mediates access to CoreData through managed object contexts.
/// This allows calling code to instantiate a new `PersistentStore` instance wherever needed.
public class PersistentStore: NSObject {
    
    static let persistentStorePath          = "victoriOS.sqlite"
    static let managedObjectModelName       = "victoriOS"
    static let managedObjectModelVersion    = "victorious-4.0"
    
    private static var sharedManager: CoreDataManager = {
        let docsDirectory = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
        let persistentStoreURL = docsDirectory.URLByAppendingPathComponent( persistentStorePath )
        
        try! NSFileManager.defaultManager().removeItemAtURL(persistentStoreURL)
        
        let momPath = ("\(managedObjectModelName).momd" as NSString).stringByAppendingPathComponent( managedObjectModelVersion )
        guard let momURLInBundle = NSBundle.mainBundle().URLForResource( momPath, withExtension: "mom" ) else {
            fatalError( "Cannot find managed object model (.mom) for URL in bundle: \(momPath)" )
        }
        
        return CoreDataManager(
            persistentStoreURL: persistentStoreURL,
            currentModelVersion: CoreDataManager.ModelVersion(
                identifier: managedObjectModelVersion,
                managedObjectModelURL: momURLInBundle
            ),
            previousModelVersion: nil
        )
    }()
    
    /// Executes a closure synchronously using the main context of the persistent store, provided
    /// as a `PersistentStoreContextBasic` type, which is designed to be used from Objective-C only.  From Swift,
    /// use `sync(_:)`, which adds a generic type for a return value (which, keep in mind, can be Void).
    public func syncBasic( closure: ((PersistentStoreContextBasic)->()) ) {
        let context = PersistentStore.sharedManager.mainContext
        context.performBlockAndWait {
            closure( context )
        }
    }
    
    /// Executes a closure synchronously using the main context of the persistent store.
    /// Keep in mind, the generic type can be Void if no result is desired.
    public func sync<T>( closure: ((PersistentStoreContext)->(T)) ) -> T {
        let context = PersistentStore.sharedManager.mainContext
        var result: T?
        context.performBlockAndWait {
            result = closure( context )
        }
        return result!
    }
    
    /// Executes a closure synchronously using the background context of the persistent store.
    /// This method should be used for any concurrent data operations, such as
    /// parsing a network response into the peristent store.
    /// Keep in mind, the generic type can be Void if no result is desired.
    public func syncFromBackground<T>( closure: ((PersistentStoreContext)->(T)) ) -> T {
        let context = PersistentStore.sharedManager.backgroundContext
        var result: T?
        context.performBlockAndWait {
            result = closure( context )
        }
        return result!
    }
    
    /// Executes a closure asynchronously using the background context of the persistent store.
    /// This method should be used for any asynchronous, concurrent data operations, such as
    /// parsing a network response into the peristent store.
    public func asyncFromBackground( closure: ((PersistentStoreContext)->()) ) {
        let context = PersistentStore.sharedManager.backgroundContext
        context.performBlock {
            closure( context )
        }
    }
}
