//
//  VStreamItem.swift
//  victorious
//
//  Created by Patrick Lynch on 2/3/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

extension VStream {
    
    var streamItems: [VStreamItem] {
        return self.streamChildren.flatMap { ($0 as? VStreamChild)?.streamItem }
    }
    
    var marqueeItems: [VStreamItem] {
        return self.marqueeChildren.flatMap { ($0 as? VStreamChild)?.streamItem }
    }
}

extension VSequence {
    
    var streamItems: [VStreamItem] {
        return []
    }
    
    var marqueeItems: [VStreamItem] {
        return []
    }
}
