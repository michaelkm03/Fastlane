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
    
    private static var sharedCoreDataManager: CoreDataManager = {
        let docsDirectory = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
        let persistentStoreURL = docsDirectory.URLByAppendingPathComponent( persistentStorePath )
        
        let momPath = ("\(managedObjectModelName).momd" as NSString).stringByAppendingPathComponent( managedObjectModelVersion )
        guard let momURLInBundle = NSBundle.mainBundle().URLForResource( momPath, withExtension: "mom" ) else {
            fatalError( "Cannot find managed object model (.mom) for URL in bundle: \(momPath)" )
        }
        
        return CoreDataManager(
            persistentStoreURL: persistentStoreURL!,
            currentModelVersion: CoreDataManager.ModelVersion(
                identifier: managedObjectModelVersion,
                managedObjectModelURL: momURLInBundle
            ),
            previousModelVersion: nil
        )
    }()
    
    var mainContext: NSManagedObjectContext {
        return MainPersistentStore.sharedCoreDataManager.mainContext
    }

    func createBackgroundContext() -> NSManagedObjectContext {
        return MainPersistentStore.sharedCoreDataManager.createBackgroundContext()
    }
}
