//
//  NSManagedObjectContext+PersistentStoreContext.swift
//  VictoriousIOSSDK
//
//  Created by Patrick Lynch on 10/26/15.
//  Copyright © 2015 Victorious, Inc. All rights reserved.
//

import Foundation

/// A Swift-only generic implementation of the PersistentStoreContextBasic protocol that provides access to a single
/// Core Data managed object context.
extension NSManagedObjectContext: PersistentStoreContext {
    
    func getObject<T: PersistentStoreObject>( identifier: AnyObject ) -> T? {
        return self.getObjectWithIdentifier( identifier ) as? T
    }
    
    func createObjectAndSave<T: PersistentStoreObject>( @noescape configurations: (T) -> () ) -> T {
        let output = self.createObjectAndSaveWithEntityName( T.dataStoreEntityName() ) { model in
            configurations( model as! T )
        }
        return output as! T
    }
    
    func createObject<T: PersistentStoreObject>() -> T {
        return self.createObjectWithEntityName( T.dataStoreEntityName() ) as! T
    }
    
    func findOrCreateObject<T: PersistentStoreObject>( queryDictionary: [ String : AnyObject ] ) -> T {
        return self.findOrCreateObjectWithEntityName( T.dataStoreEntityName(), queryDictionary: queryDictionary ) as! T
    }
    
    func findObjects<T: PersistentStoreObject>() -> [T] {
        return self.findObjectsWithEntityName( T.dataStoreEntityName(), queryDictionary: nil, limit: 0 ) as? [T] ?? []
    }
    
    func findObjects<T: PersistentStoreObject>( limit limit: Int ) -> [T] {
        return self.findObjectsWithEntityName( T.dataStoreEntityName(), queryDictionary: nil, limit: limit ) as? [T] ?? []
    }
    
    func findObjects<T: PersistentStoreObject>( queryDictionary: [ String : AnyObject ] ) -> [T] {
        return self.findObjectsWithEntityName( T.dataStoreEntityName(), queryDictionary:queryDictionary, limit: 0 ) as? [T] ?? []
    }
    
    func findObjects<T: PersistentStoreObject>( queryDictionary: [ String : AnyObject ], limit: Int ) -> [T] {
        return self.findObjectsWithEntityName( T.dataStoreEntityName(), queryDictionary:queryDictionary, limit: limit ) as? [T] ?? []
    }
    
    func cacheObject<T: PersistentStoreObject>(object: T?, forKey key: String) {
        self.cacheObject( object, forKey: key )
    }
    
    func cachedObjectForKey<T: PersistentStoreObject>(key: String) -> T? {
        return self.cachedObjectForKey( key ) as? T
    }
}