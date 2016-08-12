//
//  TestPersistentStore.swift
//  victorious
//
//  Created by Alex Tamoykin on 12/22/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation

/// A concrete implementation of `PersistentStoreType` to be used for unit tests and automation tests.
/// You may freely populate this persistent store with whatever data is required for a test as well
/// as delete any or all of its contents.
class TestPersistentStore: NSObject, PersistentStoreType {
    
    static let persistentStorePath = "victoriOS-test.sqlite"
    static let managedObjectModelName = "victoriOS"
    static let managedObjectModelVersion = MainPersistentStore.managedObjectModelVersion
    
    static func createCoreDataManager() -> CoreDataManager {
        let docsDirectory = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
        let persistentStoreURL = docsDirectory.URLByAppendingPathComponent( TestPersistentStore.persistentStorePath )
        
        let momPath = ("\(TestPersistentStore.managedObjectModelName).momd" as NSString).stringByAppendingPathComponent( TestPersistentStore.managedObjectModelVersion )
        guard let momURLInBundle = NSBundle.mainBundle().URLForResource( momPath, withExtension: "mom" ) else {
            fatalError( "Cannot find managed object model (.mom) for URL in bundle: \(momPath)" )
        }
        
        return CoreDataManager(
            persistentStoreURL: persistentStoreURL!,
            currentModelVersion: CoreDataManager.ModelVersion(
                identifier: TestPersistentStore.managedObjectModelVersion,
                managedObjectModelURL: momURLInBundle
            ),
            previousModelVersion: nil
        )
    }
    
    private static var sharedInstance: CoreDataManager? = nil
    
    static var coreDataManager: CoreDataManager {
        if let sharedInstance = sharedInstance {
            return sharedInstance
        } else {
            let newInstance = createCoreDataManager()
            sharedInstance = newInstance
            return newInstance
        }
    }
    
    var mainContext: NSManagedObjectContext {
        return TestPersistentStore.coreDataManager.mainContext
    }
    
    func createBackgroundContext() -> NSManagedObjectContext {
        return createChildContext()
    }
    
    func deletePersistentStore() {
        TestPersistentStore.sharedInstance = nil
    }
    
    private func createChildContext() -> NSManagedObjectContext {
        let context = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        context.parentContext = self.mainContext
        context.mergePolicy = NSOverwriteMergePolicy
        return context
    }
}
