//
//  DataStore.swift
//  Persistence
//
//  Created by Patrick Lynch on 10/14/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation

/// An interface that defines a object object used by the DataStore protocol.  Model types that will
/// be managed using a DataStore object must implement DataStoreObject.
@objc public protocol DataStoreObject {
    
    /// Identifies the type of the object to the store for operations such as loading, saving, etc.
    static func entityName() -> String
}

/// An interface that defines the basic behaviors of a persistent data store.
@objc public protocol DataStoreObjC {
    
    /// Writes all changes from any modified objects to the persistent store
    func saveChanges() -> Bool
    
    /// Marks an object for deletion, which will occur upon the next call to `saveChanges()`
    func destroy( object: DataStoreObject ) -> Bool
    
    /// Creates a new object of type `entityName`
    ///
    /// -parameter entityName String, the name or type of the entity to create
    func createObjectWithEntityName( entityName: String ) -> DataStoreObject
    
    /// Creates a new object of type `entityName`
    ///
    /// -parameter entityName String, the name or type of the entity to create
    /// -configurations An optional closure that is called after creating the object which allows
    /// calling code to provide values for all required attributes
    func createObjectAndSaveWithEntityName( entityName: String, @noescape configurations: DataStoreObject -> Void ) -> DataStoreObject
    
    /// Searches for objects matching the data in the query dictionary
    ///
    /// -parameter entityName String, the name or type of the entity to search for
    /// -parameter queryDictionary A dictionary of values that will be marshed into predicate used to search for matching objects
    /// -parameter limit Int, the maximum nunber of result objects to return
    func findObjectsWithEntityName( entityName: String, queryDictionary: [ String : AnyObject ]?, limit: Int ) -> [DataStoreObject]
    
    
    /// Searches for an object matching the data in the query dictionary, or creates a new object
    /// and populates it with the data in the query dictionary.
    func findOrCreateObjectWithEntityName( entityName: String, queryDictionary: [ String : AnyObject ] ) -> DataStoreObject
}


/// Adapts methods of the DataStore protocol to use generics
public protocol DataStore: DataStoreObjC {
    
    func createObjectAndSave<T: DataStoreObject>( @noescape configurations: (T) -> () ) -> T
    
    func createObject<T: DataStoreObject>() -> T
    
    func findOrCreateObject<T: DataStoreObject>( queryDictionary: [ String : AnyObject ] ) -> T
    
    func findObjects<T: DataStoreObject>( queryDictionary: [ String : AnyObject ], limit: Int  ) -> [T]
    
    func findObjects<T: DataStoreObject>( queryDictionary: [ String : AnyObject ]  ) -> [T]
    
    func findObjects<T: DataStoreObject>( limit limit: Int ) -> [T]
    
    func findObjects<T: DataStoreObject>() -> [T]
}
