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
    
    class func mapping() -> RKObjectMapping {
        var mapping = RKEntityMapping(forEntityForName: entityName(), inManagedObjectStore: RKObjectManager.sharedManager().managedObjectStore)
        mapping.identificationAttributes = ["remoteId"]
        mapping.addAttributeMappingsFromDictionary(VStream.propertyMap())
        VStream.addFeedChildMappingToMapping(mapping)
        mapping.addRelationshipMappingWithSourceKeyPath("shelves", mapping: Shelf.dynamicMapping())
        return mapping
    }
    
    override class func descriptors() -> [AnyObject] {
        //Feed parsing
        let mapping = ExploreStream.mapping()
        return [
            RKResponseDescriptor(mapping: ExploreStream.mapping(), method: RKRequestMethod.GET, pathPattern: "/api/sequence/explore/:streamId/:page/:perpage", keyPath: "payload", statusCodes: RKStatusCodeIndexSetForClass(RKStatusCodeClass.Successful)),
            RKResponseDescriptor(mapping: ExploreStream.mapping(), method: RKRequestMethod.GET, pathPattern: "/api/sequence/explore/:stream/:page/:perpage", keyPath: "payload", statusCodes: RKStatusCodeIndexSetForClass(RKStatusCodeClass.Successful)),
            RKResponseDescriptor(mapping: ExploreStream.mapping(), method: RKRequestMethod.GET, pathPattern: "/api/sequence/explore/:streamId/:filterId/:page/:perpage", keyPath: "payload", statusCodes: RKStatusCodeIndexSetForClass(RKStatusCodeClass.Successful)),
            RKResponseDescriptor(mapping: ExploreStream.mapping(), method: RKRequestMethod.GET, pathPattern: "/api/sequence/explore/:category/:filtername", keyPath: "payload", statusCodes: RKStatusCodeIndexSetForClass(RKStatusCodeClass.Successful))
        ]
    }
}
