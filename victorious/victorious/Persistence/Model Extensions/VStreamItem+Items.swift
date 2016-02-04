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
    
    /*var streamItems: [VStreamItem] {
        return []
    }
    
    var marqueeItems: [VStreamItem] {
        return []
    }*/
    
    var tracking: VTracking? {
        // FIXME: Delete this getter and have calling code read this from the stream's streamChild, not the stream item
        // This is only here to keep shit compiling
        return (self.streamChildrenInSream.first as? VStreamChild)?.tracking
    }
}
