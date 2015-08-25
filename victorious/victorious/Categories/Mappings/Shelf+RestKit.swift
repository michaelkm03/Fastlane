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
        return [
            "title" : "title",
            "streamUrl" : "streamUrl"
        ]
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
        switch itemSubType {
        case VStreamItemSubTypeMarquee:
            return mappingBaseForEntity(named: "Shelf")
        case VStreamItemSubTypeUser:
            return UserShelf.entityMapping()
        case VStreamItemSubTypeHashtag:
            return HashtagShelf.entityMapping()
        default:()
            return nil
        }
    }
    
    class func dynamicMapping() -> RKDynamicMapping {
        var dynamicMapping = RKDynamicMapping()
        dynamicMapping.addMatcher(RKObjectMappingMatcher(possibleMappings: [], block: { (mappable: AnyObject!) -> RKObjectMapping! in
            var shelfMapping: RKObjectMapping?
            if let streamItem = mappable as? VStreamItem, let subType = streamItem.itemSubType {
                shelfMapping = Shelf.mapping(subType)
            }
            return shelfMapping
        }))
        return dynamicMapping
    }
    
}