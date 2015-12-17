//
//  CoreDataManagerTests.swift
//  VictoriousIOSSDK
//
//  Created by Patrick Lynch on 10/15/15.
//  Copyright © 2015 Victorious, Inc. All rights reserved.
//

import XCTest
import CoreData
import KVOController
@testable import victorious

class CoreDataManagerTests: XCTestCase {
    
    let versionedModelName = "PersistenceTests"
    let pathHelper = CoreDataPathHelper()
    var coreDataManager: CoreDataManager!
    
    let testModelCount = 10
    let testModelEntityName = "PersistentEntity"
    var modelVersions: [String : CoreDataManager.ModelVersion]!
    var persistentStoreURL: NSURL!
    
    let text = "Hello world!"
    let updatedText = "Goodbye cruel, cruel world!"
    var kvoContext: Void
    
    override func setUp() {
        super.setUp()

        self.persistentStoreURL = self.pathHelper.applicationDocumentsDirectory.URLByAppendingPathComponent( "\(self.versionedModelName).sqlite" )
        
        // SETUP: Delete any persistent stores created from previous test sequences
        self.pathHelper.deleteFilesInDirectory( self.persistentStoreURL )
        
        self.modelVersions = [
            "1.0" : CoreDataManager.ModelVersion(
                identifier: "1.0" ,
                managedObjectModelURL: self.pathHelper.URLForManagedObjectModelInBundle(versionedModelName, modelVersion: "1.0")
            ),
            "1.1" : CoreDataManager.ModelVersion(
                identifier: "1.1" ,
                managedObjectModelURL: self.pathHelper.URLForManagedObjectModelInBundle(versionedModelName, modelVersion: "1.1")
            ),
            "2.0" : CoreDataManager.ModelVersion(
                identifier: "2.0" ,
                managedObjectModelURL: self.pathHelper.URLForManagedObjectModelInBundle(versionedModelName, modelVersion: "2.0")
            ),
        ]
    }
    
    func testMigrations() {
        
        // Reuable variables for this test
        var request: NSFetchRequest!
        var coreDataManager: CoreDataManager!
        
        // PART 1: Create a core data manager with version 1.0
        coreDataManager = CoreDataManager(
            persistentStoreURL: persistentStoreURL,
            currentModelVersion: modelVersions[ "1.0" ]!,
            previousModelVersion: nil
        )
        // Create some records to read later on
        for i in 0..<testModelCount {
            let entity = NSEntityDescription.entityForName( testModelEntityName, inManagedObjectContext:coreDataManager.mainContext)
            let model = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: coreDataManager.mainContext) as! PersistentEntity
            model.numberAttribute = NSNumber(integer: i)
            // Set the `stringAttribute` attribute in version 1.0
            model.setValue( "\(i)", forKey: "stringAttribute" )
        }
        do {
            try coreDataManager.mainContext.save()
        }
        catch {
            XCTFail( "Failed to save." )
        }
        
        // PART 2: Create a core data manager with version 1.1 to allow lightweight migration to occur
        coreDataManager = CoreDataManager(
            persistentStoreURL: persistentStoreURL,
            currentModelVersion: modelVersions[ "1.1" ]!,
            previousModelVersion: modelVersions[ "1.0" ]!
        )
        
        // Load the records we are expecting
        request = NSFetchRequest(entityName: testModelEntityName)
        request.returnsObjectsAsFaults = false
        request.fetchLimit = testModelCount
        request.sortDescriptors = [ NSSortDescriptor(key: "numberAttribute", ascending: true) ]
        
        // Ensure that the lightweight migration was successful by loading models with schema changes
        let models = try! coreDataManager.mainContext.executeFetchRequest( request ) as! [PersistentEntity]
        XCTAssertEqual( models.count, testModelCount )
        for i in 0..<models.count {
            let model = models[i]
            // Ensure that the `stringAttribute` value has been mapping to `newStringAttribute` as configured in our mapping file
            XCTAssertEqual( model.newStringAttribute, "\(i)" )
            XCTAssertEqual( model.numberAttribute!.integerValue, i )
        }
        
        // PART 3: Create a core data manager with version 2.0 of the datal model, for which we will add some custom
        // migration logic in class `PersitentEntityMigration_2_0`.
        coreDataManager = CoreDataManager(
            persistentStoreURL: persistentStoreURL,
            currentModelVersion: modelVersions[ "2.0" ]!,
            previousModelVersion: modelVersions[ "1.1" ]!
        )
        
        // Load the records we are expecting
        request = NSFetchRequest(entityName: testModelEntityName)
        request.returnsObjectsAsFaults = false
        request.fetchLimit = testModelCount
        request.sortDescriptors = [ NSSortDescriptor(key: "numberAttribute", ascending: true) ]
        
        // Ensure that the customized migration was successful
        let migratedModels = try! coreDataManager.mainContext.executeFetchRequest( request ) as! [PersistentEntity]
        XCTAssertEqual( migratedModels.count, testModelCount )
        for i in 0..<migratedModels.count {
            let model = migratedModels[i]
            XCTAssertEqual( model.newStringAttribute, "\(i)" )
            XCTAssertNotNil( model.transientEntity )
            XCTAssertEqual( model.transientEntity!.stringAttribute, "\(i)" )
            XCTAssertEqual( model.numberAttribute!.integerValue, i )
        }
    }
    
    func testConcurrentInsertion() {
        
        let versionIdentifier = "2.0"
        self.coreDataManager = CoreDataManager(
            persistentStoreURL: persistentStoreURL,
            currentModelVersion: CoreDataManager.ModelVersion(
                identifier: versionIdentifier,
                managedObjectModelURL: pathHelper.URLForManagedObjectModelInBundle( versionedModelName,
                    modelVersion: versionIdentifier )
            )
        )
        
        let callbackExpectation = self.expectationWithDescription("callback")
        
        // Insert a new object in the background context, as if from a network response
        self.coreDataManager.backgroundContext.performBlock() {
            let moc = self.coreDataManager.backgroundContext
            let entity = NSEntityDescription.entityForName( PersistentEntity.v_entityName(), inManagedObjectContext: moc)
            let persistentEntity = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: moc) as! PersistentEntity
            persistentEntity.newStringAttribute = self.text
            try! moc.save()
            let insertedObjectId = persistentEntity.objectID
            
            self.coreDataManager.mainContext.performBlock() {
                let loadedEntity = try! self.coreDataManager.mainContext.existingObjectWithID( insertedObjectId ) as! PersistentEntity
                XCTAssert( NSThread.currentThread().isMainThread )
                XCTAssertEqual( loadedEntity.objectID, persistentEntity.objectID )
                XCTAssertEqual( loadedEntity.newStringAttribute, persistentEntity.newStringAttribute )
                callbackExpectation.fulfill()
            }
        }
        
        self.waitForExpectationsWithTimeout(2, handler: nil)
    }
    
    func testConcurrentUpdate() {
        
        let versionIdentifier = "2.0"
        let momURL = pathHelper.URLForManagedObjectModelInBundle(versionedModelName, modelVersion: versionIdentifier)
        self.coreDataManager = CoreDataManager(
            persistentStoreURL: persistentStoreURL,
            currentModelVersion: CoreDataManager.ModelVersion(identifier: versionIdentifier, managedObjectModelURL: momURL)
        )
        
        let moc = coreDataManager.mainContext
        let entity = NSEntityDescription.entityForName( "PersistentEntity", inManagedObjectContext: moc)
        let persistentEntity = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: moc) as! PersistentEntity
        persistentEntity.newStringAttribute = self.text
        try! moc.save()
        
        // Observe changes to an attribute of that entity
        // See `observeValueForKeyPath(_:ofObject:change:context:)` for assertions
        let observationExpectation = self.expectationWithDescription("callback")
        
        self.KVOController.observe( persistentEntity,
            keyPath: "newStringAttribute",
            options: [],
            block: { [weak self] (observer, object, change) in
                
                XCTAssert( NSThread.currentThread().isMainThread )
                
                let updatedEntity = object as! PersistentEntity
                XCTAssertEqual( updatedEntity.newStringAttribute, self?.updatedText )
                XCTAssertEqual( persistentEntity, updatedEntity )
                
                observationExpectation.fulfill()
        })
        
        // Update the existing object in the background context, as if from a network response 
        self.coreDataManager.backgroundContext.performBlock {
            let moc = self.coreDataManager.backgroundContext
            let request = NSFetchRequest(entityName: PersistentEntity.v_entityName() )
            request.fetchLimit = 1
            request.returnsObjectsAsFaults = false
            let results = try! moc.executeFetchRequest( request )
            let persistentEntity = results.first as! PersistentEntity
            persistentEntity.newStringAttribute = self.updatedText
            try! moc.save()
        }
        
        waitForExpectationsWithTimeout(2, handler: nil)
    }
}
