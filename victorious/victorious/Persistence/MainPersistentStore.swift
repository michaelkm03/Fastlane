//
//  MainPersistentStore.swift
//  victorious
//
//  Created by Patrick Lynch on 11/23/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation

/// An object that provides access to this application's primary and only peristent store by
/// providing an implementation of `PersistentStoreType`, the interface against which all application code
/// is programmed.  See `PersistentStoreType` protocol for more information.
/// This class has an internally configured a singleton object that mediates access to CoreData through managed object contexts.
/// This allows calling code to instantiate a new `MainPersistentStore` instance wherever needed.
class MainPersistentStore: NSObject, PersistentStoreType {
    
    static let persistentStorePath          = "victoriOS.sqlite"
    static let managedObjectModelName       = "victoriOS"
    static let managedObjectModelVersion    = "victorious-4.0"
    
    private static var sharedManager: CoreDataManager = {
        let docsDirectory = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
        let persistentStoreURL = docsDirectory.URLByAppendingPathComponent( persistentStorePath )
        
        do { try NSFileManager.defaultManager().removeItemAtURL(persistentStoreURL) } catch {}
        
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
    
    // MARK: - PersistentStoreType
    
    func syncBasic( closure: ((PersistentStoreContextBasic)->()) ) {
        let context = MainPersistentStore.sharedManager.mainContext
        context.performBlockAndWait {
            closure( context )
        }
    }
    
    func sync<T>( closure: ((PersistentStoreContext)->(T)) ) -> T {
        let context = MainPersistentStore.sharedManager.mainContext
        var result: T?
        context.performBlockAndWait {
            result = closure( context )
        }
        return result!
    }
    
    func async( closure: ((PersistentStoreContext)->()) ) {
        let context = MainPersistentStore.sharedManager.mainContext
        context.performBlock {
            closure( context )
        }
    }
    
    func syncFromBackground<T>( closure: ((PersistentStoreContext)->(T)) ) -> T {
        let context = MainPersistentStore.sharedManager.backgroundContext
        var result: T?
        context.performBlockAndWait {
            result = closure( context )
        }
        return result!
    }
    
    func asyncFromBackground( closure: ((PersistentStoreContext)->()) ) {
        let context = MainPersistentStore.sharedManager.backgroundContext
        context.performBlock {
            closure( context )
        }
    }
    
    func asyncFromBackgroundBasic( closure: ((PersistentStoreContextBasic)->()) ) {
        let context = MainPersistentStore.sharedManager.backgroundContext
        context.performBlock {
            closure( context )
        }
    }
}