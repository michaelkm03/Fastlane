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

    private let persistentStorePath = "victoriOS-test.sqlite"
    private let managedObjectModelName = "victoriOS"
    private let managedObjectModelVersion = MainPersistentStore.managedObjectModelVersion
    private let sharedCoreDataManager: CoreDataManager
    private let persistentStoreURL:    NSURL

    var mainContext: NSManagedObjectContext {
        return sharedCoreDataManager.mainContext
    }

    var backgroundContext: NSManagedObjectContext {
        return sharedCoreDataManager.backgroundContext
    }

    override init() {
        do {
            let docsDirectoryURL = try NSFileManager.defaultManager().URLForDirectory(.DocumentDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: false)
            persistentStoreURL = docsDirectoryURL.URLByAppendingPathComponent(persistentStorePath)
            let momFileName    = "\(managedObjectModelName).momd" as NSString
            let momFilePath    = momFileName.stringByAppendingPathComponent(managedObjectModelVersion)

            guard let momURLInBundle = NSBundle(forClass: self.dynamicType).URLForResource(momFilePath, withExtension: "mom") else {
                fatalError("Cannot find managed object model (.mom) for URL in bundle: \(momFilePath)")
            }

            sharedCoreDataManager = CoreDataManager(
                persistentStoreURL:  persistentStoreURL,
                currentModelVersion: CoreDataManager.ModelVersion(
                    identifier: managedObjectModelVersion,
                    managedObjectModelURL: momURLInBundle
                ),
                previousModelVersion: nil
            )
        } catch {
            fatalError("Can't locate the documents directory for testing")
        }

        super.init()
    }

    func deletePersistentStore() throws {
        let fileManager = NSFileManager.defaultManager()
        if let path = persistentStoreURL.path where fileManager.fileExistsAtPath(path) {
            do {
                try NSFileManager.defaultManager().removeItemAtURL(persistentStoreURL)
            } catch {
                throw PersistentStoreError.DeleteFailed(storeURL: persistentStoreURL, error: error)
            }
        }
    }
}
