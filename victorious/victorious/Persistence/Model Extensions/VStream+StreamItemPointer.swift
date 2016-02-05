//
//  VStream+StreamItemPointer.swift
//  victorious
//
//  Created by Patrick Lynch on 2/3/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

/// This extension provides helpers for the necessarily complex relationship between
/// VStream, VStreamItem and VStreamItemPointer.
extension VStream {
    
    /// Maps stream items (as StreamItemPointer) into an array of the VStreamItems to which they point
    var streamItems: [VStreamItem] {
        return self.streamItemPointers.flatMap { ($0 as? VStreamItemPointer)?.streamItem }
    }
    
    /// Maps marquee items (as VStreamItemPointer) into an array of the VStreamItems to which they point
    var marqueeItems: [VStreamItem] {
        return self.marqueeItemPointers.flatMap { ($0 as? VStreamItemPointer)?.streamItem }
    }
    
    /// Filters the receiver's `streamItemPointers` for those whose `streamItem` is contained
    /// within the provided list of streamItemIDs.
    func streamPointers(forStreamItemIDs streamItemIDs: [String]) -> NSOrderedSet {
        let predicate = NSPredicate() { (object, bindings) in
            guard let streamPointer = object as? VStreamItemPointer else {
                return false
            }
            return streamItemIDs.contains() { streamPointer.streamItem.remoteId == $0 }
        }
        return self.streamItemPointers.filteredOrderedSetUsingPredicate( predicate )
    }
}
