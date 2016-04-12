//
//  PersistentStoreContextTests.swift
//  VictoriousIOSSDK
//
//  Created by Patrick Lynch on 10/16/15.
//  Copyright © 2015 Victorious, Inc. All rights reserved.
//

import XCTest
@testable import victorious

class PersistentStoreContextTests: XCTestCase {
    
    var coreDataManager: CoreDataManager!
    
    let versionedModelName = "PersistenceTests"
    let pathHelper = CoreDataPathHelper()
    
    let text = "Hello world!"
    let versionIdentifier = "2.0"
    let updatedText = "Goodbye cruel, cruel world!"
    
    var persistentStoreURL: NSURL {
        return pathHelper.applicationDocumentsDirectory.URLByAppendingPathComponent( "\(versionedModelName).sqlite" )
    }
    
    override func setUp() {
        super.setUp()
        
        // SETUP: Delete any persistent stores created from previous test sequences
        pathHelper.deleteFilesInDirectory( pathHelper.applicationDocumentsDirectory )
        XCTAssertFalse( NSFileManager.defaultManager().fileExistsAtPath( persistentStoreURL.absoluteString ) )
        
        self.coreDataManager = CoreDataManager(
            persistentStoreURL: persistentStoreURL,
            currentModelVersion: CoreDataManager.ModelVersion(
                identifier: versionIdentifier,
                managedObjectModelURL: pathHelper.urlForManagedObjectModelInBundle( versionedModelName,
                    modelVersion: versionIdentifier )
            )
        )
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testCreateConfiguration() {
        
        let defaultPersistentStoreContext = self.coreDataManager.mainContext
        
        defaultPersistentStoreContext.v_createObjectAndSave() { (model: PersistentEntity) in
            model.newStringAttribute = self.text
        }
        
        let knownEntity: PersistentEntity = defaultPersistentStoreContext.v_findObjects( ["newStringAttribute" : text] ).first!
        XCTAssertNotNil( knownEntity )
        XCTAssertEqual( knownEntity.newStringAttribute, text )
        
        let knownEntity2: PersistentEntity = defaultPersistentStoreContext.v_findObjects( ["newStringAttribute" : text] ).first!
        XCTAssertNotNil( knownEntity2 )
        XCTAssertEqual( knownEntity2.newStringAttribute, text )
        
        let unknownEntity: PersistentEntity? = defaultPersistentStoreContext.v_findObjects( ["newStringAttribute" : "Some other text"] ).first
        XCTAssertNil( unknownEntity )
    }
    
    func testFindAll() {
        
        let defaultPersistentStoreContext = self.coreDataManager.mainContext
        
        let count = 10
        for i in 0..<count {
            defaultPersistentStoreContext.v_createObjectAndSave() { (model: PersistentEntity) in
                model.newStringAttribute = "value \(i)"
            }
        }
        
        let allEntities: [PersistentEntity] = defaultPersistentStoreContext.v_findObjects( limit: 0 )
        XCTAssertEqual( allEntities.count, count )
        
        let limit = 5
        let someEntities: [PersistentEntity] = defaultPersistentStoreContext.v_findObjects( limit: limit )
        XCTAssertEqual( someEntities.count, limit )
    }
}
