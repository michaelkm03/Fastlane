//
//  ListShelf+RestKit.swift
//  victorious
//
//  Created by Sharif Ahmed on 8/16/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import Foundation

extension ListShelf {
    
    static private var propertyMap : [String : String] {
        return [
            "caption" : "caption",
        ]
    }
    
    override static func entityName() -> String {
        return "ListShelf"
    }
    
    override static func entityMapping() -> RKEntityMapping {
        var mapping = VShelf.mappingBaseForEntityWithName(entityName())
        mapping.addAttributeMappingsFromDictionary(propertyMap)
        return mapping
    }
    
}
