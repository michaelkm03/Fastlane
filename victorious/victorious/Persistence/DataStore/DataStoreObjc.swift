//
//  DataStoreObjc.swift
//  victorious
//
//  Created by Patrick Lynch on 11/9/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import CoreData

/// An interface that defines the basic behaviors of a persistent data store.
@objc protocol DataStoreObjC {
    
    /// Writes all changes from any modified objects to the persistent store
    func saveChanges() -> Bool
    
    /// Marks an object for deletion, which will occur upon the next call to `saveChanges()`
    func destroy( object: NSManagedObject ) -> Bool
    
    /// Creates a new object of type `entityName`
    ///
    /// -parameter entityName String, the name or type of the entity to create
    func createObjectWithEntityName( entityName: String ) -> NSManagedObject
    
    /// Creates a new object of type `entityName`
    ///
    /// -parameter entityName String, the name or type of the entity to create
    /// -configurations An optional closure that is called after creating the object which allows
    /// calling code to provide values for all required attributes
    func createObjectAndSaveWithEntityName( entityName: String, @noescape configurations: NSManagedObject -> Void ) -> NSManagedObject
    
    /// Searches for objects matching the data in the query dictionary
    ///
    /// -parameter entityName String, the name or type of the entity to search for
    /// -parameter queryDictionary A dictionary of values that will be marshed into predicate used to search for matching objects
    /// -parameter limit Int, the maximum nunber of result objects to return
    func findObjectsWithEntityName( entityName: String, queryDictionary: [ String : AnyObject ]?, limit: Int ) -> [NSManagedObject]
    
    
    /// Searches for an object matching the data in the query dictionary, or creates a new object
    /// and populates it with the data in the query dictionary.
    func findOrCreateObjectWithEntityName( entityName: String, queryDictionary: [ String : AnyObject ] ) -> NSManagedObject
}