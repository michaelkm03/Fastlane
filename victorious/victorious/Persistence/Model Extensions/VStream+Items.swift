//
//  VStream+Item.swift
//  victorious
//
//  Created by Patrick Lynch on 2/3/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

extension VStream {
    
    /// Maps the ordered set of VStreamChild into an array of VStreamItem
    var streamItems: [VStreamItem] {
        return self.streamChildren.flatMap { ($0 as? VStreamChild)?.streamItem }
    }
    
    /// Maps the ordered set of VStreamChild into an array of VStreamItem
    var marqueeItems: [VStreamItem] {
        return self.marqueeChildren.flatMap { ($0 as? VStreamChild)?.streamItem }
    }
}
