//
//  PlaylistShelf+RestKit.swift
//  victorious
//
//  Created by Sharif Ahmed on 8/16/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import Foundation

extension PlaylistShelf {
    
    static private var propertyMap : [String : String] {
        return [
            "playlistTitle" : "playlistTitle",
        ]
    }
    
    override static func entityName() -> String {
        return "PlaylistShelf"
    }
    
    override static func entityMapping() -> RKEntityMapping {
        var mapping = VShelf.mappingBaseForEntityWithName(entityName())
        mapping.addAttributeMappingsFromDictionary(propertyMap)
        return mapping
    }
    
}
