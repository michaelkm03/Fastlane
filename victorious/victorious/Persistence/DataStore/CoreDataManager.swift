//
//  CoreDataManager.swift
//  VictoriousIOSSDK
//
//  Created by Patrick Lynch on 10/14/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import CoreData

/// An object that creates and managed the Core Data stack, providing a main context and a
/// background context that are linked together for automatic merged into the main context
/// from the background context when changes are made in the background.  The entire stack
/// is initialized when CoreDataManager is initialized and does not use any lazily-loaded
/// setup methods.
class CoreDataManager: NSObject {
    
    /// An object that points to the location to one version (.mom, created from an .xcmappingmodel)
    /// of a verioned Core Data managed object model (.momd, from an .xcdatamodeld).  Note the 'd' in
    // the latter file extension, which indicates that the file is versioned.
    struct ModelVersion {
        /// The version identifier configured in the managed obejct model (e.g. "2.0")
        let identifier: String
        
        /// URL of the managed object model version in the bundle (.mom)
        let managedObjectModelURL: NSURL
        
        init( identifier: String, managedObjectModelURL: NSURL ) {
            self.identifier = identifier
            self.managedObjectModelURL = managedObjectModelURL
        }
    }
    
    let currentModelVersion: ModelVersion
    let previousModelVersion: ModelVersion?
    let persistentStoreURL: NSURL
    
    let mainContext: NSManagedObjectContext
    let backgroundContext: NSManagedObjectContext
    private let managedObjectModel: NSManagedObjectModel
    private let persistentStoreCoordinator: NSPersistentStoreCoordinator
    
    init( persistentStoreURL: NSURL, currentModelVersion: ModelVersion, previousModelVersion: ModelVersion? = nil ) {
        
        // WARNING: This is for testing only, it deletes the store on disk every time
        do { try NSFileManager.defaultManager().removeItemAtURL( persistentStoreURL ) } catch {}
        
        self.persistentStoreURL = persistentStoreURL
        self.currentModelVersion = currentModelVersion
        self.previousModelVersion = previousModelVersion
        
        self.managedObjectModel = NSManagedObjectModel(contentsOfURL: self.currentModelVersion.managedObjectModelURL )!
        self.persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        do {
            try self.persistentStoreCoordinator.addPersistentStoreWithType( NSSQLiteStoreType,
                configuration: nil,
                URL: self.persistentStoreURL,
                options: [
                    NSSQLitePragmasOption: [ "journal_mode" : "DELETE" ],
                    NSMigratePersistentStoresAutomaticallyOption : true,
                    NSInferMappingModelAutomaticallyOption : true
                ]
            )
        }
        catch {
            print( "Failed to create persistent store.  Either the managed object model and persistent store URLs provided are invalid, or a migration failed between a current and previous mapping model failed.  If you are using a mapping model, double check that all attributes and relationships are being migrated properly.  Caught error: \(error)" )
        }
        
        self.mainContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        self.mainContext.persistentStoreCoordinator = self.persistentStoreCoordinator
        
        self.backgroundContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        self.backgroundContext.persistentStoreCoordinator = self.persistentStoreCoordinator
        
        super.init()
        
        // Set up merges into the main context when changes have been saved to the background context
        // For example, network requests will make changes to the background context, which is then
        // merged into the main context that can be accessed/observed by the UI thread
        NSNotificationCenter.defaultCenter().addObserverForName( NSManagedObjectContextDidSaveNotification,
            object: self.backgroundContext,
            queue: NSOperationQueue.mainQueue()) { [weak self] notification in
                self?.mainContext.mergeChangesFromContextDidSaveNotification( notification )
        }
    }

    func deletePersistentStore() {
        do {
            try NSFileManager.defaultManager().removeItemAtURL( self.persistentStoreURL )
        } catch {
            print( "Error deleting database: \(error)" )
        }
    }
}
