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
protocol DataStoreObject : class {
    
    /// Identifies the type of the object to the store for operations such as loading, saving, etc.
    static func dataStoreEntityName() -> String
    
    var dataStore: DataStore { get }
}

extension NSManagedObject: DataStoreObject {
    
    class func dataStoreEntityName() -> String {
        return (NSStringFromClass(self) as NSString).pathExtension
    }
    
    var dataStore: DataStore {
        guard let dataStore = self.managedObjectContext as? DataStore else {
            fatalError( "There is no managed object context associated with this managed object." +
                "Most likely you are trying to perform an operation on an object that has been deleted." )
        }
        return dataStore
    }
}

/// Adapts methods of the DataStore protocol to use generics
protocol DataStore: DataStoreObjC {
    
    func createObjectAndSave<T: NSManagedObject>( @noescape configurations: (T) -> () ) -> T
    
    func createObject<T: NSManagedObject>() -> T
    
    func findOrCreateObject<T: NSManagedObject>( queryDictionary: [ String : AnyObject ] ) -> T
    
    func findObjects<T: NSManagedObject>( queryDictionary: [ String : AnyObject ], limit: Int  ) -> [T]
    
    func findObjects<T: NSManagedObject>( queryDictionary: [ String : AnyObject ]  ) -> [T]
    
    func findObjects<T: NSManagedObject>( limit limit: Int ) -> [T]
    
    func findObjects<T: NSManagedObject>() -> [T]
}
