//
//  NSManagedObjectContext+Fetchers.swift
//  Persistence
//
//  Created by Patrick Lynch on 10/15/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import CoreData

extension NSManagedObjectContext {
    
    /// Performs a save to the receiver and subsequently the reciever's `parentContext`,
    /// if defined. Also catches any exceptions, throws an assertion failure and
    /// logs detailed error messages to the console.
    func v_saveAndBubbleToParentContext() {
        v_save()
        parentContext?.v_performBlockAndWait() { context in
            context.v_save()
        }
    }
    
    /// Performs a save to the receiver and catches any exceptions, throws an assertion
    /// failure and logs detailed error messages to the console.
    func v_save() {
        do {
            try self.save()
        } catch {
            var message = "\n\n *** FAILED TO SAVE! ***\n"
            let userInfo = (error as NSError).userInfo
            var managedObject: NSManagedObject?
            if let detailedErrors = userInfo[ "NSDetailedErrors" ] as? [NSError] {
                for detailedError in detailedErrors {
                    if let validationField = detailedError.userInfo[ "NSValidationErrorKey" ] as? String,
                        let object = detailedError.userInfo[ "NSValidationErrorObject" ] as? NSManagedObject {
                            managedObject = object
                            message += "\n - Missing value for non-optional field \"\(validationField)\" on object \(managedObject?.dynamicType)."
                    }
                }
            }
            else if let validationField = userInfo[ "NSValidationErrorKey" ] as? String,
                let object = userInfo[ "NSValidationErrorObject" ] as? NSManagedObject {
                    managedObject = object
                    message += "\n - Missing value for non-optional field \"\(validationField)\" on object \(managedObject?.dynamicType)."
            }
            VLog(message + "\n\n")
            assertionFailure()
        }
    }
    
    func v_deleteObjects( fetchRequest: NSFetchRequest ) -> Bool {
        do {
            let results = try self.executeFetchRequest( fetchRequest ) as? [NSManagedObject] ?? []
            for result in results {
                deleteObject( result )
            }
            return true
        } catch {
            VLog( "Failed to delete objects with entity name \(fetchRequest.entityName): \(error)" )
            return false
        }
    }
    
    func v_deleteAllObjectsWithEntityName( entityName: String ) -> Bool {
        return v_deleteObjects( NSFetchRequest(entityName: entityName) )
    }
    
    func v_createObjectAndSaveWithEntityName( entityName: String, @noescape configurations: NSManagedObject -> Void ) -> NSManagedObject {
        let object = self.v_createObjectWithEntityName( entityName )
        configurations( object )
        self.v_save()
        return object
    }
    
    func v_createObjectWithEntityName( entityName: String ) -> NSManagedObject {

        guard let entity = NSEntityDescription.entityForName( entityName, inManagedObjectContext: self ) else {
            fatalError( "Could not find entity for name: \(entityName).  Make sure the entity name configurated in the managed object object matches the expected class type." )
        }
        
        return NSManagedObject(entity: entity, insertIntoManagedObjectContext: self) as NSManagedObject
    }
    
    func v_deleteObjectsWithEntityName( entityName: String, queryDictionary: [ String : AnyObject ]? = nil ) {
        let existingObjects = self.v_findObjectsWithEntityName( entityName, queryDictionary: queryDictionary )
        for object in existingObjects {
            self.deleteObject( object )
        }
    }
    
    func v_findOrCreateObjectWithEntityName( entityName: String, queryDictionary: [ String : AnyObject ] ) -> NSManagedObject {
        let objects = self.v_findObjectsWithEntityName( entityName, queryDictionary: queryDictionary )
        if let existingObject = objects.first {
            return existingObject
        
        } else {
            let object = self.v_createObjectWithEntityName( entityName )
            for (key, value) in queryDictionary where (value as? String) != "nil" && !(value is [String : AnyObject]) && !(key.containsString(".")) {
                object.setValue( value, forKey: key)
            }
            return object
        }
    }
    
    func v_findAllObjectsWithEntityName( entityName: String ) -> [NSManagedObject] {
        return v_findObjectsWithEntityName( entityName, queryDictionary: nil )
    }
    
    func v_findObjectsWithEntityName( entityName: String, queryDictionary: [ String : AnyObject ]? ) -> [NSManagedObject] {
        
        let request = NSFetchRequest(entityName: entityName)
        request.returnsObjectsAsFaults = false
        
        if let queryDictionary = queryDictionary {
            let arguments = NSMutableArray()
            var format = String()
            var i = 0
            for (attribute, value) in queryDictionary {
                let connector = i++ < queryDictionary.count-1 ? " && " : ""
                if let dict = value as? [String : AnyObject] {
                    let subAttribute = Array(dict.keys)[0]
                    if let subValue = dict[subAttribute] {
                        format += "ANY self.\(attribute).\(subAttribute) = %@\(connector)"
                        arguments.addObject( subValue )
                    }
                } else {
                    format += "(\(attribute) == %@)\(connector)"
                    arguments.addObject( value )
                }
            }
            request.predicate = NSPredicate(format: format, argumentArray: arguments as [AnyObject] )
        }
        
        do {
            if let results = try self.executeFetchRequest( request ) as? [NSManagedObject] {
                return results
            }
        } catch {
            VLog( "Error: \(error)" )
        }
        return [NSManagedObject]()
    }
    
    func v_displayOrderForNewObjectWithEntityName( entityName: String, predicate: NSPredicate? = nil ) -> Int {
        let request = NSFetchRequest(entityName: entityName)
        request.sortDescriptors = [ NSSortDescriptor(key: "displayOrder", ascending: false) ]
        if let predicate = predicate {
            request.predicate = predicate
        }
        request.fetchBatchSize = 1
        request.fetchLimit = 1
        
        do {
            let results = try executeFetchRequest( request )
            if let lowestDisplayOrderObject = results.first as? PaginatedObjectType {
                let lowestDisplayOrder = (lowestDisplayOrderObject.displayOrder.integerValue ?? 0)
                return lowestDisplayOrder - 1
            }
        } catch {
            VLog( "Error: \(error)" )
        }
        return -1
    }
}
