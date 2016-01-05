//
//  NSManagedObjectContext+Generics.swift
//  VictoriousIOSSDK
//
//  Created by Patrick Lynch on 10/26/15.
//  Copyright © 2015 Victorious, Inc. All rights reserved.
//

import Foundation

/// A Swift-only generic implementation of the PersistentStoreContextBasic protocol that provides access to a single
/// Core Data managed object context.
extension NSManagedObjectContext {
    
    func v_objectWithID<T: NSManagedObject>( objectID: NSManagedObjectID ) -> T? {
        return self.objectWithID( objectID ) as? T
    }
    
    func v_createObjectAndSave<T: NSManagedObject>( @noescape onBeforeSave: (T) -> () ) -> T {
        let output = self.v_createObjectAndSaveWithEntityName( T.v_entityName() ) { model in
            onBeforeSave( model as! T )
        }
        return output as! T
    }
    
    func v_createObject<T: NSManagedObject>() -> T {
        return self.v_createObjectWithEntityName( T.v_entityName() ) as! T
    }
    
    func v_findOrCreateObject<T: NSManagedObject>( queryDictionary: [ String : AnyObject ] ) -> T {
        return self.v_findOrCreateObjectWithEntityName( T.v_entityName(), queryDictionary: queryDictionary ) as! T
    }

    func v_findObjects<T: NSManagedObject>( queryDictionary: [ String : AnyObject ] ) -> [T] {
        return v_findObjectsWithEntityName( T.v_entityName(), queryDictionary: queryDictionary ) as? [T] ?? []
    }
    
    func v_findAllObjects<T: NSManagedObject>() -> [T] {
        return v_findAllObjectsWithEntityName( T.v_entityName() ) as? [T] ?? []
    }
}
