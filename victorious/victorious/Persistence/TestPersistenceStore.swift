//
//  TestPersistenceStore.swift
//  victorious
//
//  Created by Alex Tamoykin on 12/22/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

class TestPersistentStore: NSObject, PersistentStoreType {

    let persistentStorePath       = "victoriOS-test.sqlite"
    let managedObjectModelName    = "victoriOS-test"
    let managedObjectModelVersion = MainPersistentStore.managedObjectModelVersion

    var mainContext: NSManagedObjectContext {
        return sharedCoreDataManager.mainContext
    }

    var backgroundContext: NSManagedObjectContext {
        return sharedCoreDataManager.backgroundContext
    }

    private let sharedCoreDataManager: CoreDataManager

    override init() {
        do {
            let docsDirectoryURL = try NSFileManager.defaultManager().URLForDirectory(.DocumentDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: false)
            let persistentStoreURL = docsDirectoryURL.URLByAppendingPathComponent(persistentStorePath)
            let momFileName        = "\(managedObjectModelName).momd" as NSString
            let momFilePath        = momFileName.stringByAppendingPathComponent(managedObjectModelVersion)
            guard let momURLInBundle = NSBundle.mainBundle().URLForResource(momFilePath, withExtension: "mom") else {
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
            fatalError("Can't located the documents directory for testing")
        }

        super.init()
    }
}
