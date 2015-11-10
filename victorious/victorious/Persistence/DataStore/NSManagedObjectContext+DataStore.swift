//
//  ContextDataStore+DataStore.swift
//  VictoriousIOSSDK
//
//  Created by Patrick Lynch on 10/26/15.
//  Copyright © 2015 Victorious, Inc. All rights reserved.
//

import Foundation

/// Adds implementations for the methods in the DataStore extension
extension NSManagedObjectContext: DataStore {
    
    func getObject<T: NSManagedObject>( identifier: AnyObject ) -> T? {
        return self.getObjectWithIdentifier( identifier ) as? T
    }
    
    func createObjectAndSave<T: NSManagedObject>( @noescape configurations: (T) -> () ) -> T {
        let output = self.createObjectAndSaveWithEntityName( T.dataStoreEntityName() ) { model in
            configurations( model as! T )
        }
        return output as! T
    }
    
    func createObject<T: NSManagedObject>() -> T {
        return self.createObjectWithEntityName( T.dataStoreEntityName() ) as! T
    }
    
    func findOrCreateObject<T: NSManagedObject>( queryDictionary: [ String : AnyObject ] ) -> T {
        return self.findOrCreateObjectWithEntityName( T.dataStoreEntityName(), queryDictionary: queryDictionary ) as! T
    }
    
    func findObjects<T: NSManagedObject>() -> [T] {
        return self.findObjectsWithEntityName( T.dataStoreEntityName(), queryDictionary: nil, limit: 0 ) as? [T] ?? []
    }
    
    func findObjects<T: NSManagedObject>( limit limit: Int ) -> [T] {
        return self.findObjectsWithEntityName( T.dataStoreEntityName(), queryDictionary: nil, limit: limit ) as? [T] ?? []
    }
    
    func findObjects<T: NSManagedObject>( queryDictionary: [ String : AnyObject ] ) -> [T] {
        return self.findObjectsWithEntityName( T.dataStoreEntityName(), queryDictionary:queryDictionary, limit: 0 ) as? [T] ?? []
    }
    
    func findObjects<T: NSManagedObject>( queryDictionary: [ String : AnyObject ], limit: Int ) -> [T] {
        return self.findObjectsWithEntityName( T.dataStoreEntityName(), queryDictionary:queryDictionary, limit: limit ) as? [T] ?? []
    }
}