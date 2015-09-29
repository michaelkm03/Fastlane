//
//  HashtagShelf+RestKit.swift
//  victorious
//
//  Created by Sharif Ahmed on 8/12/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import Foundation

extension HashtagShelf {
    
    static private var propertyMap : [String : String] {
        return [
            "postCount" : "postsCount"
        ]
    }
    
    override static func entityMapping() -> RKEntityMapping {
        let mapping = Shelf.mappingBaseForEntity(named: HashtagShelf.entityName())
        let relationship = RKRelationshipMapping(fromKeyPath: "hashtag", toKeyPath: "hashtagObject", withMapping: VHashtag.entityMapping())
        mapping.addPropertyMapping(relationship)
        mapping.addAttributeMappingsFromDictionary(propertyMap)
        return mapping
    }
    
}
