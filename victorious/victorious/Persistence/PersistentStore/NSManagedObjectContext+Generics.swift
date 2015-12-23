//
//  NSManagedObjectContext+PersistentStoreContext.swift
//  VictoriousIOSSDK
//
//  Created by Patrick Lynch on 10/26/15.
//  Copyright © 2015 Victorious, Inc. All rights reserved.
//

import Foundation

public struct PersistentStorePagination {
    let itemsPerPage: Int
    let pageNumber: Int
    let sortDescriptors: [NSSortDescriptor]
    
    public init( itemsPerPage: Int, pageNumber: Int, sortDescriptors: [NSSortDescriptor] = [] ) {
        self.itemsPerPage = itemsPerPage
        self.pageNumber = pageNumber
        self.sortDescriptors = sortDescriptors
    }
}

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
    
    func v_findObjects<T: NSManagedObject>( queryDictionary: [ String : AnyObject ]?, pagination: PersistentStorePagination?, limit: Int? ) -> [T] {
        return self.v_findObjectsWithEntityName( T.v_entityName(),
            queryDictionary: queryDictionary,
            pageNumber: pagination?.pageNumber,
            itemsPerPage: pagination?.itemsPerPage,
            sortDescriptors: pagination?.sortDescriptors ?? [],
            limit: limit
        ) as? [T] ?? []
    }
    
    func v_cacheObject<T: NSManagedObject>(object: T?, forKey key: String) {
        self.v_cacheObject( object, forKey: key )
    }
    
    func v_cachedObjectForKey<T: NSManagedObject>(key: String) -> T? {
        return self.v_cachedObjectForKey( key ) as? T
    }
    
    func v_findObjects<T: NSManagedObject>( limit limit: Int ) -> [T] {
        return v_findObjects( nil, pagination: nil, limit: limit)
    }
    
    func v_findObjects<T: NSManagedObject>( queryDictionary: [ String : AnyObject ], limit: Int ) -> [T] {
        return v_findObjects( queryDictionary, pagination: nil, limit: limit)
    }
    
    func v_findObjects<T: NSManagedObject>( queryDictionary: [ String : AnyObject ] ) -> [T] {
        return v_findObjects( queryDictionary, pagination: nil, limit: nil)
    }
    
    func v_findObjects<T: NSManagedObject>( queryDictionary: [ String : AnyObject ], pagination: PersistentStorePagination ) -> [T] {
        return v_findObjects( queryDictionary, pagination: pagination, limit: nil)
    }
    
    func v_findAllObjects<T: NSManagedObject>() -> [T] {
        return v_findObjects( nil, pagination: nil, limit: nil)
    }
    
    func v_findAllObjects<T: NSManagedObject>( pagination pagination: PersistentStorePagination ) -> [T] {
        return v_findObjects( nil, pagination: pagination, limit: nil)
    }
}