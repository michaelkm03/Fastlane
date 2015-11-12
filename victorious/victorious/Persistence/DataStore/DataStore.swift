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
public protocol DataStoreObject : class {
    
    /// Identifies the type of the object to the store for operations such as loading, saving, etc.
    static func dataStoreEntityName() -> String
    
    var dataStore: DataStore { get }
    
    var identifier: AnyObject { get }
}

extension NSManagedObject: DataStoreObject {
    
    public class func dataStoreEntityName() -> String {
        let className = (NSStringFromClass(self) as NSString)
        if className.pathExtension.characters.count > 0 {
            return className.pathExtension
        }
        else if className.substringToIndex(1) == "V" {
            return className.substringFromIndex(1)
        }
        else {
            return className as String
        }
    }
    
    public var dataStore: DataStore {
        guard let dataStore = self.managedObjectContext as? DataStore else {
            fatalError( "There is no managed object context associated with this managed object." +
                "Most likely you are trying to perform an operation on an object that has been deleted." )
        }
        return dataStore
    }
    
    public var identifier: AnyObject {
        return self.objectID
    }
}

/// Adapts methods of the DataStore protocol to use generics
public protocol DataStore: DataStoreBasic {
    
    func getObject<T: DataStoreObject>( identifier: AnyObject ) -> T?
    
    func createObjectAndSave<T: NSManagedObject>( @noescape configurations: (T) -> () ) -> T
    
    func createObject<T: NSManagedObject>() -> T
    
    func findOrCreateObject<T: NSManagedObject>( queryDictionary: [ String : AnyObject ] ) -> T
    
    func findObjects<T: NSManagedObject>( queryDictionary: [ String : AnyObject ], limit: Int  ) -> [T]
    
    func findObjects<T: NSManagedObject>( queryDictionary: [ String : AnyObject ]  ) -> [T]
    
    func findObjects<T: NSManagedObject>( limit limit: Int ) -> [T]
    
    func findObjects<T: NSManagedObject>() -> [T]
}
