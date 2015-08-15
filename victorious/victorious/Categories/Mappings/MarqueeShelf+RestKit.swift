//
//  MarqueeShelf+RestKit.swift
//  victorious
//
//  Created by Sharif Ahmed on 8/12/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import Foundation

extension MarqueeShelf {
    
    override static func entityName() -> String {
        return "MarqueeShelf"
    }
    
    override static func entityMapping() -> RKEntityMapping {
        return VShelf.mappingBaseForEntityWithName(MarqueeShelf.entityName())
    }
    
}
