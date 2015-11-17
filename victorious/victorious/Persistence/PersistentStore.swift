//
//  Persistence.swift
//  victorious
//
//  Created by Patrick Lynch on 11/5/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

@objc public class PersistentStore: NSObject {
    
    private static var instance: CoreDataManager? = nil
    
    static let persistentStorePath = "victoriOS.sqlite"
    static let managedObjectModelName = "victoriOS"
    static let managedObjectModelVersion = "victorious-4.0"
    
    private static var sharedManager: CoreDataManager {
        if instance == nil {
            let docsDirectory = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
            let persistentStoreURL = docsDirectory.URLByAppendingPathComponent( persistentStorePath )
            
            // try! NSFileManager.defaultManager().removeItemAtURL(persistentStoreURL)
            
            let momPath = ("\(managedObjectModelName).momd" as NSString).stringByAppendingPathComponent( managedObjectModelVersion )
            guard let momURLInBundle = NSBundle.mainBundle().URLForResource( momPath, withExtension: "mom" ) else {
                fatalError( "Cannot find managed object model (.mom) for URL in bundle: \(momPath)" )
            }
            
            instance = CoreDataManager(
                persistentStoreURL: persistentStoreURL,
                currentModelVersion: CoreDataManager.ModelVersion(
                    identifier: managedObjectModelVersion,
                    managedObjectModelURL: momURLInBundle
                ),
                previousModelVersion: nil
            )
        }
        return instance!
    }
    
    static var mainContext: DataStore {
        return PersistentStore.sharedManager.mainContext
    }
    
    static var backgroundContext: DataStore {
        return PersistentStore.sharedManager.backgroundContext
    }
    
    public static func getMainContext() -> DataStoreBasic {
        return self.mainContext
    }
    
    public static var getBackgroundContext: DataStoreBasic {
        return self.backgroundContext
    }
}