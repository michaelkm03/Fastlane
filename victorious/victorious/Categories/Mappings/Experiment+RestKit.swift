//
//  Experiment+RestKit.swift
//  victorious
//
//  Created by Patrick Lynch on 7/21/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import Foundation

extension Experiment {
    
    static var propertyMap: [String:String] {
        return [
            "name" : "name",
            "id" : "id"
        ]
    }
    
    static var entityMapping: RKEntityMapping {
        var store = RKObjectManager.sharedManager().managedObjectStore
        var mapping = RKEntityMapping(forEntityForName: self.v_defaultEntityName, inManagedObjectStore: store )
        mapping.addAttributeMappingsFromDictionary( propertyMap )
        mapping.identificationAttributes = [ "id" ]
        return mapping
    }
    
    static var descriptors: NSArray {
        return [
            RKResponseDescriptor(
                mapping: self.entityMapping,
                method: .Any,
                pathPattern: "/api/device/experiments",
                keyPath: "payload",
                statusCodes: RKStatusCodeIndexSetForClass(UInt(RKStatusCodeClassSuccessful))
            )
        ]
    }
    
    var dictionary: [String : AnyObject] {
        return [
            "name" : self.name,
            "id" : self.id,
            "enabled" : self.enabled
        ]
    }
}