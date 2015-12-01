//
//  NSManagedObject+Extensions_Tests.swift
//  victorious
//
//  Created by Patrick Lynch on 12/1/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import XCTest
import CoreData
@testable import victorious

class NSManagedObject_Extensions_Tests: XCTestCase {
    
    let versionedModelName = "PersistenceTests"
    var coreDataManager: CoreDataManager!
    var persistentStoreURL: NSURL!
    let pathHelper = CoreDataPathHelper()
    
    override func setUp() {
        super.setUp()

        self.persistentStoreURL = self.pathHelper.applicationDocumentsDirectory.URLByAppendingPathComponent( "\(self.versionedModelName).sqlite" )
        
        // SETUP: Delete any persistent stores created from previous test sequences
        self.pathHelper.deleteFilesInDirectory( self.persistentStoreURL )
        
        let versionIdentifier = "2.0"
        self.coreDataManager = CoreDataManager(
            persistentStoreURL: persistentStoreURL,
            currentModelVersion: CoreDataManager.ModelVersion(
                identifier: versionIdentifier,
                managedObjectModelURL: pathHelper.URLForManagedObjectModelInBundle( versionedModelName,
                    modelVersion: versionIdentifier )
            )
        )
    }
    
    func testRelationships() {
        let moc = self.coreDataManager.mainContext

        let parent: PersistentEntity = {
            let entity = NSEntityDescription.entityForName( PersistentEntity.dataStoreEntityName(), inManagedObjectContext: moc)
            return NSManagedObject(entity: entity!, insertIntoManagedObjectContext: moc) as! PersistentEntity
        }()
        parent.newStringAttribute = "parent"
        
        var children = [PersistentEntity]()
        for i in 0..<10 {
            let child: PersistentEntity = {
                let entity = NSEntityDescription.entityForName( PersistentEntity.dataStoreEntityName(), inManagedObjectContext: moc)
                return NSManagedObject(entity: entity!, insertIntoManagedObjectContext: moc) as! PersistentEntity
            }()
            child.newStringAttribute = "child_\(i)"
            children.append( child )
        }
        
        XCTAssertEqual( parent.children.count, 0 )
        
        parent.addObject( children[0], to: "children" )
        XCTAssertEqual( parent.children.count, 1 )
        XCTAssertEqual( parent.children.flatMap({ $0 as? PersistentEntity })[0], children[0] )
        XCTAssertNotNil( children[0].parent )
        XCTAssertEqual( children[0].parent, parent )
        
        parent.removeObject( children[0], from: "children" )
        XCTAssertNil( children[0].parent )
        XCTAssertEqual( parent.children.count, 0 )
        
        parent.addObjects( children, to: "children" )
        XCTAssertEqual( parent.children.count, children.count )
        let persistentChidlren = parent.children.flatMap({ $0 as? PersistentEntity })
        XCTAssertEqual( persistentChidlren[0], children[0] )
        for i in 0..<children.count {
            XCTAssertEqual( children[i], persistentChidlren[i] )
            XCTAssertNotNil( children[i].parent )
            XCTAssertEqual( children[i].parent, parent )
        }
        
        parent.removeObjects( children, from: "children" )
        for i in 0..<children.count {
            XCTAssertNil( children[i].parent )
        }
        XCTAssertEqual( parent.children.count, 0 )
    }
    
    func testCopy() {
        let text = "Hello World"
        let date = NSDate()
        
        let moc = self.coreDataManager.mainContext
        let persistentEntity: PersistentEntity = {
            let entity = NSEntityDescription.entityForName( PersistentEntity.dataStoreEntityName(), inManagedObjectContext: moc)
            return NSManagedObject(entity: entity!, insertIntoManagedObjectContext: moc) as! PersistentEntity
        }()
        let transientEntity: TransientEntity = {
            let entity = NSEntityDescription.entityForName( TransientEntity.dataStoreEntityName(), inManagedObjectContext: moc)
            return NSManagedObject(entity: entity!, insertIntoManagedObjectContext: moc) as! TransientEntity
        }()
        persistentEntity.transientEntity = transientEntity
        persistentEntity.newStringAttribute = text
        persistentEntity.dateAttribute = date
        
        let shallowCopy = persistentEntity.shallowCopy() as! PersistentEntity
        XCTAssertNotEqual( shallowCopy, persistentEntity )
        XCTAssertNil( shallowCopy.transientEntity )
        XCTAssertEqual( shallowCopy.newStringAttribute, persistentEntity.newStringAttribute )
        XCTAssertEqual( shallowCopy.dateAttribute, date )
    }
}
