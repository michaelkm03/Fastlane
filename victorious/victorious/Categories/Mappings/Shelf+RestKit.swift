//
//  Shelf+RestKit.swift
//  victorious
//
//  Created by Sharif Ahmed on 8/19/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import Foundation

extension Shelf {
    
    override class func entityName() -> String {
        return v_defaultEntityName
    }
    
    class func propertyMapping() -> [String : String] {
        return [
            "title" : "title",
            "streamUrl" : "streamUrl"
        ]
    }
    
    class func mappingBaseForEntity(named entityName: String) -> RKEntityMapping {
        let mapping = RKEntityMapping(forEntityForName: entityName, inManagedObjectStore: RKObjectManager.sharedManager().managedObjectStore)
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
        case VStreamItemSubTypeTrendingTopic:
            return mappingBaseForEntity(named: "Shelf")
        case VStreamItemSubTypeMarquee:
            return mappingBaseForEntity(named: entityName())
        case VStreamItemSubTypeUser:
            return UserShelf.entityMapping()
        case VStreamItemSubTypeHashtag:
            return HashtagShelf.entityMapping()
        case VStreamItemSubTypePlaylist, VStreamItemSubTypeRecent:
            return ListShelf.entityMapping()
        default:()
            return nil
        }
    }
    
    class func dynamicMapping() -> RKDynamicMapping {
        let dynamicMapping = RKDynamicMapping()
        dynamicMapping.addMatcher(RKObjectMappingMatcher(possibleMappings: [], block: { (mappable: AnyObject!) -> RKObjectMapping! in
            var shelfMapping: RKObjectMapping?
            if let dictionary = mappable as? [String : AnyObject], let subtype = dictionary["subtype"] as? String {
                shelfMapping = Shelf.mapping(subtype)
            }
            return shelfMapping
        }))
        return dynamicMapping
    }
    
}