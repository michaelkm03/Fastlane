//
//  NSManagedObjectContext+PersistentStoreContextBasic.swift
//  Persistence
//
//  Created by Patrick Lynch on 10/15/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import CoreData

extension NSManagedObjectContext {
    
    func v_save() -> Bool {
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
    
    func v_findOrCreateObjectWithEntityName( entityName: String, queryDictionary: [ String : AnyObject ] ) -> NSManagedObject {
        let objects = self.v_findObjectsWithEntityName( entityName,
            queryDictionary: queryDictionary,
            pageNumber: nil,
            itemsPerPage: nil,
            limit: NSNumber(integer: 1)
        )
        if let existingObject = objects.first {
            return existingObject
        }
        else {
            let object = self.v_createObjectWithEntityName( entityName )
            for (key, value) in queryDictionary {
                object.setValue(value, forKey: key)
            }
            return object
        }
    }
    
    func v_findObjectsWithEntityName( entityName: String, queryDictionary: [ String : AnyObject ] ) -> [NSManagedObject] {
        return v_findObjectsWithEntityName( entityName, queryDictionary: queryDictionary, pageNumber: nil, itemsPerPage: nil, limit: nil)
    }
    
    func v_findObjectsWithEntityName( entityName: String, queryDictionary: [ String : AnyObject ]?, pageNumber: NSNumber?, itemsPerPage: NSNumber?, limit: NSNumber? ) -> [NSManagedObject] {
        
        let request = NSFetchRequest(entityName: entityName )
        request.returnsObjectsAsFaults = false
        if let limit = limit {
            request.fetchLimit = limit.integerValue
        }
        if let itemsPerPage = itemsPerPage, let pageNumber = pageNumber {
            request.fetchLimit = itemsPerPage.integerValue
            request.fetchOffset = pageNumber.integerValue * itemsPerPage.integerValue
        }
        
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
            print( "Error: \(error)" )
        }
        return [NSManagedObject]()
    }
}
