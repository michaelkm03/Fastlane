//
//  VStream+Item.swift
//  victorious
//
//  Created by Patrick Lynch on 2/3/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

extension VStream {
    
    /// Maps the ordered set of VStreamItemPointer into an array of VStreamItem
    var streamItems: [VStreamItem] {
        return self.streamItemPointers.flatMap { ($0 as? VStreamItemPointer)?.streamItem }
    }
    
    /// Maps the ordered set of VStreamItemPointer into an array of VStreamItem
    var marqueeItems: [VStreamItem] {
        return self.marqueeItemPointers.flatMap { ($0 as? VStreamItemPointer)?.streamItem }
    }
}
