//
//  Shelf+RestKit.swift
//  victorious
//
//  Created by Sharif Ahmed on 8/19/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import Foundation

extension Shelf {
    
    class func propertyMapping() -> [String : String] {
        return ["title" : "title"]
    }
    
    class func mappingBaseForEntity(named entityName: String) -> RKEntityMapping {
        var mapping = RKEntityMapping(forEntityForName: entityName, inManagedObjectStore: RKObjectManager.sharedManager().managedObjectStore)
        mapping.identificationAttributes = ["remoteId"]
        var attributesMapping = VStream.propertyMap()
        for (key, value) in self.propertyMapping() {
            attributesMapping[key] = value
        }
        mapping.addAttributeMappingsFromDictionary(attributesMapping)
        VStream.addFeedChildMappingToMapping(mapping)
        return mapping
    }
    
    class func mapping(itemSubType: String) -> RKObjectMapping? {
        var mapping: RKObjectMapping?
        switch itemSubType {
        case VStreamItemSubTypeMarquee:
            mapping = mappingBaseForEntity(named: "Shelf")
        case VStreamItemSubTypeUser:
            mapping = UserShelf.entityMapping()
        case VStreamItemSubTypeHashtag:
            mapping = HashtagShelf.entityMapping()
        default:()
        }
        return mapping
    }
    
}