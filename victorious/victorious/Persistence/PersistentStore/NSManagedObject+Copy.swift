//
//  NSManagedObject+Copy.swift
//  victorious
//
//  Created by Patrick Lynch on 7/9/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import Foundation
import CoreData

extension NSManagedObject {
    
    func v_deepCopy( desinationContext: NSManagedObjectContext? = nil ) -> NSManagedObject {
        let context = desinationContext ?? self.managedObjectContext
        let copy = self.v_shallowCopy( desinationContext )
        
        // Copy relationships to shallow copy, making it "deep"
        for (key, relatiionship) in self.entity.relationshipsByName {
            if relatiionship.toMany {
                let source = self.mutableSetValueForKey( key )
                let destination = copy.mutableSetValueForKey( key )
                for value in source {
                    if let value = value as? NSManagedObject {
                        destination.addObject( value.v_deepCopy(context) )
                    }
                }
            }
            else if let object = self.valueForKey(key) as? NSManagedObject where object != self {
                copy.setValue( object.v_shallowCopy( context ), forKey: key)
            }
        }
        return copy
    }
    
    func v_shallowCopy( desinationContext: NSManagedObjectContext? = nil ) -> NSManagedObject {
        let context = desinationContext ?? self.managedObjectContext
        let copy = NSManagedObject(entity: self.entity, insertIntoManagedObjectContext: context )
        
        // Attributes
        let keys = (self.entity.attributesByName as NSDictionary).allKeys as? [String] ?? [String]()
        let keyedValues = self.dictionaryWithValuesForKeys( keys )
        copy.setValuesForKeysWithDictionary( keyedValues )
        
        return copy
    }
}
