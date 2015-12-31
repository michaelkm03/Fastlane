//
//  SampleCoreDataModels.swift
//  VictoriousIOSSDK
//
//  Created by Patrick Lynch on 10/16/15.
//  Copyright © 2015 Victorious, Inc. All rights reserved.
//

import Foundation
import CoreData

/// Models compatible with "2.0.xcdatamodel"

public class Library_2_0: NSManagedObject {
    @NSManaged public var name: String
    @NSManaged public var address: String
    @NSManaged public var books: NSOrderedSet
}

public class Author_2_0: NSManagedObject {
    @NSManaged public var name: String
    @NSManaged public var books: NSOrderedSet
    @NSManaged public var publishers: Set<Publisher_2_0>
}

public class Book_2_0: NSManagedObject {
    @NSManaged public var datePublished: NSDate
    @NSManaged public var title: String
    @NSManaged public var author: Author_2_0
    @NSManaged public var library: Library_2_0?
    @NSManaged public var checkedOut: NSNumber
}

public class Publisher_2_0: NSManagedObject {
    @NSManaged public var title: String
    @NSManaged public var books: NSOrderedSet
    @NSManaged public var authors: Set<Author_2_0>
}


/// Models compatible with "1.0.xcdatamodel"

public class Library_1_0: NSManagedObject {
    @NSManaged public var name: String
    @NSManaged public var dateOpened: NSDate
    @NSManaged public var books: NSOrderedSet
}

public class Author_1_0: NSManagedObject {
    @NSManaged public var name: String
    @NSManaged public var books: NSOrderedSet
}

public class Book_1_0: NSManagedObject {
    @NSManaged public var datePublished: NSDate
    @NSManaged public var title: String
    @NSManaged public var author: Author_1_0
    @NSManaged public var library: Library_1_0?
    @NSManaged public var checkedOut: NSNumber
}


func createBook_1_0( title: String, by authorName: String, inContext context: NSManagedObjectContext ) -> Book_1_0 {
    
    let book: Book_1_0 = {
        let entity = NSEntityDescription.entityForName( "Book", inManagedObjectContext: context)
        return NSManagedObject(entity: entity!, insertIntoManagedObjectContext: context) as! Book_1_0
    }()
    book.author = {
        let entity = NSEntityDescription.entityForName( "Author", inManagedObjectContext: context)
        return NSManagedObject(entity: entity!, insertIntoManagedObjectContext: context) as! Author_1_0
        }()
    book.datePublished = NSDate()
    book.author.name = authorName
    book.title = title
    return book
}

func createBook_2_0( title: String, by authorName: String, inContext context: NSManagedObjectContext ) -> Book_2_0 {
    
    let book: Book_2_0 = {
        let entity = NSEntityDescription.entityForName( "Book", inManagedObjectContext: context)
        return NSManagedObject(entity: entity!, insertIntoManagedObjectContext: context) as! Book_2_0
    }()
    book.author = {
        let entity = NSEntityDescription.entityForName( "Author", inManagedObjectContext: context)
        return NSManagedObject(entity: entity!, insertIntoManagedObjectContext: context) as! Author_2_0
    }()
    book.datePublished = NSDate()
    book.author.name = authorName
    book.title = title
    return book
}
