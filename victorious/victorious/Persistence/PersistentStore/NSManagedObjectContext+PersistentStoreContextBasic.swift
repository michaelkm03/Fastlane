//
//  NSManagedObjectContext+PersistentStoreContextBasic.swift
//  Persistence
//
//  Created by Patrick Lynch on 10/15/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import CoreData

private let SingleObjectCacheKey = "SingleObjectCache"

/// An implementation of the PersistentStoreContextBasic protocol that provides access to a single
/// Core Data managed object context.
extension NSManagedObjectContext: PersistentStoreContextBasic {
    
    func saveChanges() -> Bool {
        do {
            try self.save()
            return true
        } catch {
            if let object = (error as NSError).userInfo[ "NSValidationErrorObject" ] as? NSManagedObject {
                print( "\t- Validation failed on object \(object.dynamicType)." )
            }
            if let detailedErrors = (error as NSError).userInfo[ "NSDetailedErrors" ] as? [NSError] {
                for detailedError in detailedErrors {
                    if let validationField = detailedError.userInfo[ "NSValidationErrorKey" ] as? String,
                        let object = detailedError.userInfo[ "NSValidationErrorObject" ] as? NSManagedObject {
                            print( "\t- Missing value for non-optional field \"\(validationField)\" on object \(object.dynamicType)." )
                    }
                }
            }
            fatalError( "Failed to save." )
        }
        return false
    }
    
    func destroy( object: PersistentStoreObject ) -> Bool {
        self.deleteObject( object as! NSManagedObject )
        do {
            try self.save()
        } catch {
            print( "Failed to delete object: \(error)" )
            
        }
        return false
    }
    
    func createObjectAndSaveWithEntityName( entityName: String, @noescape configurations: PersistentStoreObject -> Void ) -> PersistentStoreObject {
        let object = self.createObjectWithEntityName( entityName )
        configurations( object )
        self.saveChanges()
        return object
    }
    
    func createObjectWithEntityName( entityName: String ) -> PersistentStoreObject {

        guard let entity = NSEntityDescription.entityForName( entityName, inManagedObjectContext: self ) else {
            fatalError( "Could not find entity for name: \(entityName).  Make sure the entity name configurated in the managed object object matches the expected class type." )
        }
        
        return NSManagedObject(entity: entity, insertIntoManagedObjectContext: self) as PersistentStoreObject
    }
    
    func findOrCreateObjectWithEntityName( entityName: String, queryDictionary: [ String : AnyObject ] ) -> PersistentStoreObject {
        if let existingObject = self.findObjectsWithEntityName( entityName, queryDictionary: queryDictionary, limit: 1).first {
            return existingObject
        }
        else {
            let object = self.createObjectWithEntityName( entityName )
            for (key, value) in queryDictionary {
                (object as! NSManagedObject).setValue(value, forKey: key)
            }
            return object
        }
    }
    
    func findObjectsWithEntityName( entityName: String, queryDictionary: [ String : AnyObject ]?, limit: Int ) -> [PersistentStoreObject] {
        
        let request = NSFetchRequest(entityName: entityName )
        request.returnsObjectsAsFaults = false
        request.fetchLimit = limit
        
        if let queryDictionary = queryDictionary {
            let arguments = NSMutableArray()
            var format = String()
            var i = 0
            for (attribute, value) in queryDictionary {
                let connector = i++ < queryDictionary.count-1 ? " && " : " "
                format += "(\(attribute) == %@)\(connector)"
                arguments.addObject( value )
            }
            request.predicate = NSPredicate(format: format, argumentArray: arguments as [AnyObject] )
        }
        
        do {
            if let results = try self.executeFetchRequest( request ) as? [PersistentStoreObject] {
                return results
            }
        } catch {
            print( "Error: \(error)" )
        }
        return [PersistentStoreObject]()
    }
    
    func getObjectWithIdentifier(identifier: AnyObject) -> PersistentStoreObject? {
        return self.objectWithID( identifier as! NSManagedObjectID ) as PersistentStoreObject
    }
    
    func cacheObject(object: PersistentStoreObject?, forKey key: String) {
        var cache = userInfo[SingleObjectCacheKey] as? [String : PersistentStoreObject] ?? [:]
        if let object = object {
            cache[key] = object
        } else {
            cache.removeValueForKey(key)
        }
        userInfo[SingleObjectCacheKey] = cache
    }
    
    func cachedObjectForKey(key: String) -> PersistentStoreObject? {
        guard let cache = userInfo[SingleObjectCacheKey] as? [String : NSManagedObject] else {
            return nil
        }
        return cache[key] as? PersistentStoreObject
    }
}
