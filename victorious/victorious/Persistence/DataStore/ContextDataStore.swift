//
//  ContextDataStore.swift
//  Persistence
//
//  Created by Patrick Lynch on 10/15/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import CoreData

@objc enum ContextDataStoreType: Int {
    case Main
    case Background
}

@objc class ContextDataStoreObject : NSManagedObject {
    
    func identifier() -> AnyObject { return self.objectID }
    
    lazy var dataStore: DataStore = {
        return ContextDataStore( managedObjectContext: self.managedObjectContext! )
    }()
}

/// In implementation of the DataSource protocol that provides access to a single CoreData managed object context.
///
/// Given the context-oriented design of CoreData, this DataStore implementation also requires
/// that an unchangeable ContextDataStoreType value be provided to properly select the right CoreData context
/// on which to operate.  In this way, this DataStore implementation provides a per-context interface
/// into a single CoreData-managed persistent store.  So there is one store/database per CoreDataManager
/// instance, and one DataStore imeplementation per context.
@objc class ContextDataStore: NSObject, DataStore {
    
    let managedObjectContext: NSManagedObjectContext
    
    required init(managedObjectContext: NSManagedObjectContext) {
        self.managedObjectContext = managedObjectContext
    }
    
    func saveChanges() -> Bool {
        do {
            try self.managedObjectContext.save()
            return true
        } catch {
            print( "Failed to save entity:" )
            if let detailedErrors = (error as NSError).userInfo[ "NSDetailedErrors" ] as? [NSError] {
                for detailedError in detailedErrors {
                    if let validationField = detailedError.userInfo[ "NSValidationErrorKey" ] as? String {
                        print( "\t- Missing value for non-optional field \"\(validationField)\"" )
                    }
                }
            }
        }
        return false
    }
    
    func destroy( object: DataStoreObject ) -> Bool {
        
        self.managedObjectContext.deleteObject( object as! NSManagedObject )
        do {
            try self.managedObjectContext.save()
        } catch {
            print( "Failed to delete object: \(error)" )
            
        }
        return false
    }
    
    func createObjectAndSaveWithEntityName( entityName: String, @noescape configurations: DataStoreObject -> Void ) -> DataStoreObject {
        let object = self.createObjectWithEntityName( entityName )
        configurations( object )
        self.saveChanges()
        return object
    }
    
    func createObjectWithEntityName( entityName: String ) -> DataStoreObject {

        guard let entity = NSEntityDescription.entityForName( entityName, inManagedObjectContext: self.managedObjectContext ) else {
            fatalError( "Could not find entity for name: \(entityName).  Make sure the entity name configurated in the managed object object matches the expected class type." )
        }
        
        let m = NSManagedObject(entity: entity, insertIntoManagedObjectContext: self.managedObjectContext)
        guard let object = m as? DataStoreObject else {
            fatalError( "Could not createObject new \(entityName).  Make sure that all optional fields are defined in the `configuration` block or before saving." )
        }
        
        return object
    }
    
    func findOrCreateObjectWithEntityName( entityName: String, queryDictionary: [ String : AnyObject ] ) -> DataStoreObject {
        if let existingObject = self.findObjectsWithEntityName( entityName, queryDictionary: queryDictionary, limit: 1).first {
            return existingObject
        }
        else {
            let object = self.createObjectWithEntityName( entityName )
            let managedObject = object as! NSManagedObject
            for (key, value) in queryDictionary {
                managedObject.setValue(value, forKey: key)
            }
            return object
        }
    }
    
    func findObjectsWithEntityName( entityName: String, queryDictionary: [ String : AnyObject ]?, limit: Int ) -> [DataStoreObject] {
        
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
            if let results = try self.managedObjectContext.executeFetchRequest( request ) as? [DataStoreObject] {
                return results
            }
        } catch {
            print( "Error: \(error)" )
        }
        return [DataStoreObject]()
    }
    
    func getObjectWithIdentifier(identifier: AnyObject) -> DataStoreObject? {
        return self.managedObjectContext.objectWithID( identifier as! NSManagedObjectID ) as? DataStoreObject
    }
}
