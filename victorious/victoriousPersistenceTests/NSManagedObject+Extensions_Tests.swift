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

    override func tearDown() {
        // CLEANUP: Delete any persistent stores created from previous test sequences
        self.pathHelper.deleteItemAtURL( self.persistentStoreURL )
    }
    
    override func setUp() {
        super.setUp()

        self.persistentStoreURL = self.pathHelper.applicationDocumentsDirectory.URLByAppendingPathComponent( "\(self.versionedModelName).sqlite" )
        
        // SETUP: Delete any persistent stores created from previous test sequences
        self.pathHelper.deleteItemAtURL( self.persistentStoreURL )
        
        let versionIdentifier = "1.0"
        self.coreDataManager = CoreDataManager(
            persistentStoreURL: persistentStoreURL,
            currentModelVersion: CoreDataManager.ModelVersion(
                identifier: versionIdentifier,
                managedObjectModelURL: pathHelper.urlForManagedObjectModelInBundle( versionedModelName,
                    modelVersion: versionIdentifier )
            )
        )
    }
    
    func testRelationships() {
        let moc = self.coreDataManager.mainContext

        let library: Library_1_0 = {
            let entity = NSEntityDescription.entityForName("Library", inManagedObjectContext: moc)
            return NSManagedObject(entity: entity!, insertIntoManagedObjectContext: moc) as! Library_1_0
        }()
        library.name = "The New York Public Library"
        library.dateOpened = NSDate()
        
        var books = [Book_1_0]()
        for i in 0..<10 {
            books.append( createBook_1_0( "Book_\(i)", by: "Author_\(i)", inContext: moc ) )
        }
        XCTAssertEqual( library.books.count, 0 )
        
        library.v_addObject( books[0], to: "books" )
        XCTAssertEqual( library.books.count, 1 )
        XCTAssertEqual( library.books.flatMap({ $0 as? Book_1_0 })[0], books[0] )
        XCTAssertNotNil( books[0].library )
        XCTAssertEqual( books[0].library, library )
        
        library.v_removeObject( books[0], from: "books" )
        XCTAssertNil( books[0].library )
        XCTAssertEqual( library.books.count, 0 )
        
        library.v_addObjects( books, to: "books" )
        XCTAssertEqual( library.books.count, books.count )
        let persistentChidlren = library.books.flatMap({ $0 as? Book_1_0 })
        XCTAssertEqual( persistentChidlren[0], books[0] )
        for i in 0..<books.count {
            XCTAssertEqual( books[i], persistentChidlren[i] )
            XCTAssertNotNil( books[i].library )
            XCTAssertEqual( books[i].library, library )
        }
        
        library.v_removeObjects( books, from: "books" )
        for i in 0..<books.count {
            XCTAssertNil( books[i].library )
        }
        XCTAssertEqual( library.books.count, 0 )
    }
    
    func testCopy() {
        let moc = self.coreDataManager.mainContext
        let book = createBook_1_0( "Jurassic Park", by: "Michael Chrichton", inContext: moc )
        
        let library: Library_1_0 = {
            let entity = NSEntityDescription.entityForName("Library", inManagedObjectContext: moc)
            return NSManagedObject(entity: entity!, insertIntoManagedObjectContext: moc) as! Library_1_0
        }()
        library.name = "The New York Public Library"
        library.dateOpened = NSDate()
        library.v_addObject( book, to: "books" )

        
        guard let shallowCopy = library.v_shallowCopy() as? Library_1_0 else {
            XCTFail( "Failed to returned a copy" )
            return
        }
        XCTAssertNotEqual( shallowCopy, library )
        XCTAssertEqual( shallowCopy.books.count, 0 )
        XCTAssertEqual( shallowCopy.name, library.name )
        XCTAssertEqual( shallowCopy.dateOpened, library.dateOpened )
    }
}
