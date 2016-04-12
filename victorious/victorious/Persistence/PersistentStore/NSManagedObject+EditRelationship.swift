//
//  NSManagedObject+EditRelationship.swift
//  victorious
//
//  Created by Patrick Lynch on 12/17/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import CoreData

extension NSManagedObject {
    
    func v_addObjects( objects: [NSManagedObject], to relationshipName: String ) {
        assert( self.entity.relationshipsByName.keys.contains( relationshipName ),
            "Could not find a relationship on entity of type '\(self.entity.name)' for key '\(relationshipName)'" )
        
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
    
    func v_addObject( object: NSManagedObject, to relationshipName: String ) {
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
    
    func v_removeObjects( objects: [NSManagedObject], from relationshipName: String ) {
        assert( self.entity.relationshipsByName.keys.contains( relationshipName ),
            "Could not find a relationship for key '\(relationshipName)'" )
        
        for (name, relationship) in self.entity.relationshipsByName where name == relationshipName {
            assert( relationship.toMany,
                "Relationship with name '\(relationshipName)' is now a to-many relationship." )
            
            if relationship.ordered {
                self.mutableOrderedSetValueForKey(relationshipName).removeObjectsInArray(objects)
            } else {
                assert( false, "Cannot remove multiple objects from unordered relationship '\(relationshipName)'" )
            }
        }
    }
    
    func v_removeAllObjects( from relationshipName: String ) {
        assert( self.entity.relationshipsByName.keys.contains( relationshipName ),
            "Could not find a relationship for key '\(relationshipName)'" )
        
        for (name, relationship) in self.entity.relationshipsByName where name == relationshipName {
            assert( relationship.toMany,
                "Relationship with name '\(relationshipName)' is now a to-many relationship." )
            
            if relationship.ordered {
                self.mutableOrderedSetValueForKey(relationshipName).removeAllObjects()
            } else {
                self.mutableSetValueForKey(relationshipName).removeAllObjects()
            }
        }
    }
    
    func v_removeObject( object: NSManagedObject, from relationshipName: String ) {
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
