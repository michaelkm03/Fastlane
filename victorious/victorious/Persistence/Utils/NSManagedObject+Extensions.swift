//
//  NSManagedObject+Extensions.swift
//  victorious
//
//  Created by Patrick Lynch on 7/9/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import Foundation
import CoreData

extension NSManagedObject {
    
    /// Returns the class name as a string, intended to match that which is configured in the MOM file.
    static var v_defaultEntityName: String {
        return StringFromClass(self)
    }
    
    func deepCopy( desinationContext: NSManagedObjectContext? = nil ) -> NSManagedObject {
        let context = desinationContext ?? self.managedObjectContext
        let copy = self.shallowCopy( desinationContext )
        
        // Copy relationships to shallow copy, making it "deep"
        for (key, relatiionship) in self.entity.relationshipsByName {
            if relatiionship.toMany {
                let source = self.mutableSetValueForKey( key )
                let destination = copy.mutableSetValueForKey( key )
                for value in source {
                    destination.addObject( value.deepCopy(context) )
                }
            }
            else if let object = self.valueForKey(key) as? NSManagedObject where object != self {
                copy.setValue( object.shallowCopy( context ), forKey: key)
            }
        }
        return copy
    }
    
    func shallowCopy( desinationContext: NSManagedObjectContext? = nil ) -> NSManagedObject {
        let context = desinationContext ?? self.managedObjectContext
        let copy = NSManagedObject(entity: self.entity, insertIntoManagedObjectContext: context )
        
        // Attributes
        let keys = (self.entity.attributesByName as NSDictionary).allKeys as? [String] ?? [String]()
        let keyedValues = self.dictionaryWithValuesForKeys( keys )
        copy.setValuesForKeysWithDictionary( keyedValues )
        
        return copy
    }
    
    func addObjects( objects: [NSManagedObject], to relationshipName: String ) {
        assert( self.entity.relationshipsByName.keys.contains( relationshipName ),
            "Could not find a relationship for key '\(relationshipName)'" )
        
        for (name, relationship) in self.entity.relationshipsByName where name == relationshipName {
            assert( relationship.toMany,
                "Relationship with name '\(relationshipName)' is now a to-many relationship." )
            
            if relationship.ordered {
                self.mutableOrderedSetValueForKey(relationshipName).addObjectsFromArray(objects)
            } else {
                self.mutableSetValueForKey(relationshipName).addObjectsFromArray(objects)
            }
        }
    }
    
    func addObject( object: NSManagedObject, to relationshipName: String ) {
        assert( self.entity.relationshipsByName.keys.contains( relationshipName ),
            "Could not find a relationship for key '\(relationshipName)'" )
        
        for (name, relationship) in self.entity.relationshipsByName where name == relationshipName {
            assert( relationship.toMany,
                "Relationship with name '\(relationshipName)' is now a to-many relationship." )
            
            if relationship.ordered {
                self.mutableOrderedSetValueForKey(relationshipName).addObject(object)
            } else {
                self.mutableSetValueForKey(relationshipName).addObject(object)
            }
        }
    }
    
    func removeObjects( objects: [NSManagedObject], from relationshipName: String ) {
        assert( self.entity.relationshipsByName.keys.contains( relationshipName ),
            "Could not find a relationship for key '\(relationshipName)'" )
        
        for (name, relationship) in self.entity.relationshipsByName where name == relationshipName {
            assert( relationship.toMany,
                "Relationship with name '\(relationshipName)' is now a to-many relationship." )
            
            if relationship.ordered {
                self.mutableOrderedSetValueForKey(relationshipName).removeObjectsInArray(objects)
            } else {
                assert( false, "Cannot remove multiple objects from ordered relationship '\(relationshipName)'" )
            }
        }
    }
    
    func removeObject( object: NSManagedObject, from relationshipName: String ) {
        assert( self.entity.relationshipsByName.keys.contains( relationshipName ),
            "Could not find a relationship for key '\(relationshipName)'" )
        
        for (name, relationship) in self.entity.relationshipsByName where name == relationshipName {
            assert( relationship.toMany,
                "Relationship with name '\(relationshipName)' is now a to-many relationship." )
            
            if relationship.ordered {
                self.mutableOrderedSetValueForKey(relationshipName).removeObject(object)
            } else {
                self.mutableSetValueForKey(relationshipName).removeObject(object)
            }
        }
    }
}
