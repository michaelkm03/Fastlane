//
//  UserShelf+RestKit.swift
//  victorious
//
//  Created by Sharif Ahmed on 8/12/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import Foundation

extension UserShelf {
    
    static private var propertyMap : [String : String] {
        return [
            "postCount" : "postsCount",
            "followersCount" : "followersCount"
        ]
    }
    
    override static func entityMapping() -> RKEntityMapping {
        let mapping = Shelf.mappingBaseForEntity(named: UserShelf.v_entityName())
        mapping.addRelationshipMappingWithSourceKeyPath("user", mapping: VUser.entityMapping())
        mapping.addAttributeMappingsFromDictionary(propertyMap)
        return mapping
    }
    
}
