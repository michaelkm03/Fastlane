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
            "hashtag" : "hashtagTitle",
            "postCount" : "postsCount"
        ]
    }
    
    override static func entityMapping() -> RKEntityMapping {
        var mapping = Shelf.mappingBaseForEntity(named: HashtagShelf.entityName())
        mapping.addAttributeMappingsFromDictionary(propertyMap)
        return mapping
    }
    
}
