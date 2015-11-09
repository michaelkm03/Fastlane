//
//  ContextDataStore+DataStore.swift
//  VictoriousIOSSDK
//
//  Created by Patrick Lynch on 10/26/15.
//  Copyright © 2015 Victorious, Inc. All rights reserved.
//

import Foundation

/// Adds implementations for the methods in the DataStore extension
extension ContextDataStore {
    
    func getObject<T: DataStoreObject>( identifier: AnyObject ) -> T? {
        return self.getObjectWithIdentifier( identifier ) as? T
    }
    
    func createObjectAndSave<T: DataStoreObject>( @noescape configurations: (T) -> () ) -> T {
        let output = self.createObjectAndSaveWithEntityName( T.entityName() ) { model in
            configurations( model as! T )
        }
        return output as! T
    }
    
    func createObject<T: DataStoreObject>() -> T {
        return self.createObjectWithEntityName( T.entityName() ) as! T
    }
    
    func findOrCreateObject<T: DataStoreObject>( queryDictionary: [ String : AnyObject ] ) -> T {
        return self.findOrCreateObjectWithEntityName( T.entityName(), queryDictionary: queryDictionary ) as! T
    }
    
    func findObjects<T: DataStoreObject>() -> [T] {
        return self.findObjectsWithEntityName( T.entityName(), queryDictionary: nil, limit: 0 ) as? [T] ?? []
    }
    
    func findObjects<T: DataStoreObject>( limit limit: Int ) -> [T] {
        return self.findObjectsWithEntityName( T.entityName(), queryDictionary: nil, limit: limit ) as? [T] ?? []
    }
    
    func findObjects<T: DataStoreObject>( queryDictionary: [ String : AnyObject ] ) -> [T] {
        return self.findObjectsWithEntityName( T.entityName(), queryDictionary:queryDictionary, limit: 0 ) as? [T] ?? []
    }
    
    func findObjects<T: DataStoreObject>( queryDictionary: [ String : AnyObject ], limit: Int ) -> [T] {
        return self.findObjectsWithEntityName( T.entityName(), queryDictionary:queryDictionary, limit: limit ) as? [T] ?? []
    }
}