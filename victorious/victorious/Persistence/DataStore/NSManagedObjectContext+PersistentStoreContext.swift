//
//  NSManagedObjectContext+PersistentStoreContext.swift
//  VictoriousIOSSDK
//
//  Created by Patrick Lynch on 10/26/15.
//  Copyright © 2015 Victorious, Inc. All rights reserved.
//

import Foundation

/// Adds implementations for the methods in the PersistentStoreContext extension
extension NSManagedObjectContext: PersistentStoreContext {
    
    public func getObject<T: PersistentStoreObject>( identifier: AnyObject ) -> T? {
        return self.getObjectWithIdentifier( identifier ) as? T
    }
    
    public func createObjectAndSave<T: PersistentStoreObject>( @noescape configurations: (T) -> () ) -> T {
        let output = self.createObjectAndSaveWithEntityName( T.dataStoreEntityName() ) { model in
            configurations( model as! T )
        }
        return output as! T
    }
    
    public func createObject<T: PersistentStoreObject>() -> T {
        return self.createObjectWithEntityName( T.dataStoreEntityName() ) as! T
    }
    
    public func findOrCreateObject<T: PersistentStoreObject>( queryDictionary: [ String : AnyObject ] ) -> T {
        return self.findOrCreateObjectWithEntityName( T.dataStoreEntityName(), queryDictionary: queryDictionary ) as! T
    }
    
    public func findObjects<T: PersistentStoreObject>() -> [T] {
        return self.findObjectsWithEntityName( T.dataStoreEntityName(), queryDictionary: nil, limit: 0 ) as? [T] ?? []
    }
    
    public func findObjects<T: PersistentStoreObject>( limit limit: Int ) -> [T] {
        return self.findObjectsWithEntityName( T.dataStoreEntityName(), queryDictionary: nil, limit: limit ) as? [T] ?? []
    }
    
    public func findObjects<T: PersistentStoreObject>( queryDictionary: [ String : AnyObject ] ) -> [T] {
        return self.findObjectsWithEntityName( T.dataStoreEntityName(), queryDictionary:queryDictionary, limit: 0 ) as? [T] ?? []
    }
    
    public func findObjects<T: PersistentStoreObject>( queryDictionary: [ String : AnyObject ], limit: Int ) -> [T] {
        return self.findObjectsWithEntityName( T.dataStoreEntityName(), queryDictionary:queryDictionary, limit: limit ) as? [T] ?? []
    }
    
    public func cacheObject<T: PersistentStoreObject>(object: T?, forKey key: String) {
        self.cacheObject( object, forKey: key )
    }
    
    public func cachedObjectForKey<T: PersistentStoreObject>(key: String) -> T? {
        return self.cachedObjectForKey( key ) as? T
    }
}