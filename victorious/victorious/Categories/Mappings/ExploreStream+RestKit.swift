//
//  ExploreStream+RestKit.swift
//  victorious
//
//  Created by Sharif Ahmed on 8/24/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import Foundation

extension ExploreStream {
    
    override static func entityName() -> String {
        return "ExploreStream"
    }
    
    class func mapping() -> RKEntityMapping {
        var mapping = RKEntityMapping(forEntityForName: entityName(), inManagedObjectStore: RKObjectManager.sharedManager().managedObjectStore)
        mapping.identificationAttributes = ["remoteId"]
        mapping.addAttributeMappingsFromDictionary(VStream.propertyMap())
        VStream.addFeedChildMappingToMapping(mapping)
        mapping.addRelationshipMappingWithSourceKeyPath("shelves", mapping: Shelf.dynamicMapping())
        return mapping
    }
    
    override class func descriptors() -> [AnyObject] {
        let mapping = ExploreStream.mapping()
        return [
            RKResponseDescriptor(mapping: mapping, method: RKRequestMethod.GET, pathPattern: "/api/sequence/explore/:page/:perpage", keyPath: "payload", statusCodes: RKStatusCodeIndexSetForClass(RKStatusCodeClass.Successful)),
        ]
    }
}
