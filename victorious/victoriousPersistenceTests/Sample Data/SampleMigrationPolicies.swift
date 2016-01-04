//
//  SampleMigrationPolicies.swift
//  VictoriousIOSSDK
//
//  Created by Patrick Lynch on 10/19/15.
//  Copyright © 2015 Victorious, Inc. All rights reserved.
//

import Foundation
import CoreData

/// This class prepresents a sample migration to version 2.0 of the PersistenceTests model
/// This class name must be configured in the *Custom Policy* field of the mapping model for this version.
@objc class PersistentEntityMigration_2_0: NSEntityMigrationPolicy {
    
    /// This is the main method to override when customizing a migration, but there also others
    /// for more complex transformations of data from one version to another.  See the header for
    /// `NSEntityMigrationPolicy` and the CoreData docs for more information.
    override func createDestinationInstancesForSourceInstance(sInstance: NSManagedObject, entityMapping mapping: NSEntityMapping, manager: NSMigrationManager) throws {
        
        if let destinationEntityName = mapping.destinationEntityName,
            let modelVersion = mapping.userInfo?[ "modelVersion" ] as? String
            where modelVersion == "2" { //< The `modelVersion` key is set in the mapping model file ("1.1-2.0.xcmappingmodel")
                
                let sourceKeys = Array(sInstance.entity.attributesByName.keys)
                let sourceValues = sInstance.dictionaryWithValuesForKeys( sourceKeys )
                let destinationInstance = NSEntityDescription.insertNewObjectForEntityForName(destinationEntityName, inManagedObjectContext: manager.destinationContext )
                
                // Handle migrating attributes by just assigning the value from the source to the destination
                // This is the default migration policy that occurs in lightweight migrations as well as calling super
                for key in Array(destinationInstance.entity.attributesByName.keys) {
                    if let value = sourceValues[ key ] where !(value is NSNull) {
                        destinationInstance.setValue(value, forKey: key)
                    }
                }
                
                // Handle migrating relationships.  Here we are going to demonsrate something custom.
                // In version 2.0 of the model, we added a relationship between `PersistentEntity` and `TransientEntity`.
                // In this migration, we want to create a new `TransientEntity` for each `transientEntity` relatinoship field,
                // otherwise it will be its default value of `nil`.  Furthermore, we're going to copy some data from the
                // `newStringAttribute` value to `stringAttribute` of the new `TransientEntity`.
                for key in Array(destinationInstance.entity.relationshipsByName.keys) {
                    switch key {
                    case "transientEntity":
                        let transientEntity = NSEntityDescription.insertNewObjectForEntityForName( "TransientEntity", inManagedObjectContext: manager.destinationContext )
                        let newStringValue = destinationInstance.valueForKey( "newStringAttribute" )
                        transientEntity.setValue( newStringValue, forKey: "stringAttribute" )
                        destinationInstance.setValue( transientEntity, forKey: key)
                    default:()
                    }
                }
        }
        else {
            try! super.createDestinationInstancesForSourceInstance( sInstance, entityMapping: mapping, manager: manager)
        }
    }
}
