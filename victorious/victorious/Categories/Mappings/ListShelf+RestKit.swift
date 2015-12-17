//
//  ListShelf+RestKit.swift
//  victorious
//
//  Created by Sharif Ahmed on 8/16/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import Foundation

extension ListShelf {
    
    static private var propertyMap: [String : String] {
        return [
            "caption" : "caption",
        ]
    }
    
    override static func entityMapping() -> RKEntityMapping {
        let mapping = Shelf.mappingBaseForEntity(named: v_entityName())
        mapping.addAttributeMappingsFromDictionary(propertyMap)
        return mapping
    }
    
}
