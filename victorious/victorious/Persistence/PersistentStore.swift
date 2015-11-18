//
//  Persistence.swift
//  victorious
//
//  Created by Patrick Lynch on 11/5/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

/// An object that can be instantiated to provide access to this application's primary peristent store.
/// It has internally configured a singleton instance of the concrete persistence implementation, which all
/// instances of `PersistentStore` will interact with.  When the needs of this application expand beyond using
/// a single persistent store, this class will need to be modified to support that.
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
    
    public var mainContext: DataStore {
        return PersistentStore.sharedManager.mainContext
    }
    
    public var backgroundContext: DataStore {
        return PersistentStore.sharedManager.backgroundContext
    }
    
    public func mainContextBasic() -> DataStoreBasic {
        return PersistentStore.sharedManager.mainContext
    }
    
    public func backgroundContextBasic() -> DataStoreBasic {
        return PersistentStore.sharedManager.backgroundContext
    }
}