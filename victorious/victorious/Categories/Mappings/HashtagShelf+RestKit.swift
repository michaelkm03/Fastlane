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
            "postCount" : "postsCount",
            "hashtag.tag" : "hashtagTitle",
            "hashtag.am_following" : "amFollowing"
        ]
    }
    
    override static func entityMapping() -> RKEntityMapping {
        let mapping = Shelf.mappingBaseForEntity( named: HashtagShelf.v_entityName() )
        mapping.addAttributeMappingsFromDictionary(propertyMap)
        return mapping
    }
}
