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
    var objectForKVO: NSManagedObject!
    let testModelCount = 10
    var modelVersions: [String : CoreDataManager.ModelVersion]!
    var persistentStoreURL: NSURL!
    
    let text = "Hello world!"
    let updatedText = "Goodbye cruel, cruel world!"
    var kvoContext: Void
    
    override func tearDown() {
        // CLEANUP: Delete any persistent stores created from previous test sequences
        self.pathHelper.deleteItemAtURL( self.persistentStoreURL )

        super.tearDown()
    }
    
    override func setUp() {
        super.setUp()

        self.persistentStoreURL = self.pathHelper.applicationDocumentsDirectory.URLByAppendingPathComponent( "\(self.versionedModelName).sqlite" )
        
        // SETUP: Delete any persistent stores created from previous test sequences
        self.pathHelper.deleteItemAtURL( self.persistentStoreURL )
        
        self.modelVersions = [
            "1.0" : CoreDataManager.ModelVersion(
                identifier: "1.0" ,
                managedObjectModelURL: self.pathHelper.URLForManagedObjectModelInBundle(versionedModelName, modelVersion: "1.0")
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
        
        // Create a core data manager with version 1.0
        coreDataManager = CoreDataManager(
            persistentStoreURL: persistentStoreURL,
            currentModelVersion: modelVersions[ "1.0" ]!,
            previousModelVersion: nil
        )
        // Create some records to read later on
        for i in 0..<testModelCount {
            createBook_1_0( "Book_\(i)", by: "Author_\(i)", inContext: coreDataManager.mainContext )
        }
        do {
            try coreDataManager.mainContext.save()
        }
        catch {
            XCTFail( "Failed to save." )
        }
        
        // Create a core data manager with version 2.0 of the datal model, for which we will add some custom
        // migration logic in class `PersitentEntityMigration_2_0`.
        coreDataManager = CoreDataManager(
            persistentStoreURL: persistentStoreURL,
            currentModelVersion: modelVersions[ "2.0" ]!,
            previousModelVersion: modelVersions[ "1.0" ]!
        )
        
        // Load the records we are expecting
        request = NSFetchRequest(entityName: "Book")
        request.returnsObjectsAsFaults = false
        request.fetchLimit = testModelCount
        request.sortDescriptors = [ NSSortDescriptor(key: "title", ascending: true) ]
        
        // Ensure that the customized migration was successful
        let migratedModels = try! coreDataManager.mainContext.executeFetchRequest( request ) as! [Book_2_0]
        XCTAssertEqual( migratedModels.count, testModelCount )
        for i in 0..<migratedModels.count {
            let model = migratedModels[i]
            XCTAssertEqual( model.title, "Book_\(i)" )
            XCTAssertEqual( model.author.name, "Author_\(i)" )
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
            let book = createBook_2_0( "Jurassic Park", by: "Michael Chrichton", inContext: moc )
            try! moc.save()
            let insertedObjectId = book.objectID
            
            self.coreDataManager.mainContext.performBlock() {
                let loadedEntity = try! self.coreDataManager.mainContext.existingObjectWithID( insertedObjectId ) as! Book_2_0
                XCTAssert( NSThread.currentThread().isMainThread )
                XCTAssertEqual( loadedEntity.objectID, book.objectID )
                XCTAssertEqual( loadedEntity.title, book.title )
                callbackExpectation.fulfill()
            }
        }
        
        self.waitForExpectationsWithTimeout(2, handler: nil)
    }
    
    func testConcurrentUpdate() {
        let newTitle = "The Lost World"

        let versionIdentifier = "2.0"
        let momURL = pathHelper.URLForManagedObjectModelInBundle(versionedModelName, modelVersion: versionIdentifier)
        self.coreDataManager = CoreDataManager(
            persistentStoreURL: persistentStoreURL,
            currentModelVersion: CoreDataManager.ModelVersion(identifier: versionIdentifier, managedObjectModelURL: momURL)
        )
        
        let moc = coreDataManager.mainContext
        self.objectForKVO = createBook_2_0( "Jurassic Park", by: "Michael Chrichton", inContext: moc )
        try! moc.save()
        
        // Observe changes to an attribute of that entity
        // See `observeValueForKeyPath(_:ofObject:change:context:)` for assertions
        let observationExpectation = self.expectationWithDescription("callback")
        
        self.KVOController.observe( self.objectForKVO,  keyPath: "title",  options: [],
            block: { (observer, object, change) in
                
                XCTAssert( NSThread.currentThread().isMainThread )
                
                let book = self.objectForKVO as! Book_2_0
                
                let updatedEntity = object as! Book_2_0
                XCTAssertEqual( updatedEntity.title, newTitle )
                XCTAssertEqual( book, updatedEntity )
                
                observationExpectation.fulfill()
        })
        
        // Update the existing object in the background context, as if from a network response 
        self.coreDataManager.backgroundContext.performBlock {
            let moc = self.coreDataManager.backgroundContext
            let request = NSFetchRequest(entityName: "Book" )
            request.returnsObjectsAsFaults = false
            let results = try! moc.executeFetchRequest( request )
            let book = results.first as! Book_2_0
            XCTAssertEqual( results.count, 1 )
            XCTAssertEqual( book.objectID, self.objectForKVO!.objectID )
            book.title = newTitle
            try! moc.save()
        }
        
        waitForExpectationsWithTimeout(2, handler: nil)
    }
}
