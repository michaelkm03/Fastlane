//
//  VStreamItem+Pointer.swift
//  victorious
//
//  Created by Patrick Lynch on 2/4/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

/// The extensions in this file provide helpers for the necessarily
/// complex relationship between VStream, VStreamItem and VStreamItemPointer.

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
    func streamItemPointers(forStreamItemIDs streamItemIDs: [String]) -> NSOrderedSet {
        let predicate = NSPredicate() { (object, bindings) in
            guard let streamItemPointer = object as? VStreamItemPointer else {
                return false
            }
            return streamItemIDs.contains() { streamItemPointer.streamItem.remoteId == $0 }
        }
        return self.streamItemPointers.filteredOrderedSetUsingPredicate( predicate )
    }
}

extension VStreamItem {
    
    /// Provides a `VTracking` object most appropriate sequence in the context
    /// of the provided stream. If the caller legimiately has no reference to a
    /// stream or streamID (such as a deeplinked sequence or the lightweight content
    /// view sequence), use `trackingForStandloneSequence` instead.
    func streamItemPointer(streamID streamID: String) -> VStreamItemPointer? {
        return self.streamItemPointer(forStreamID: streamID)
    }
    
    /// Provides a `VTracking` for standalone sequences, i.e. those that did
    /// not come from a stream or a marquee.  If the caller has a reference to
    /// a stream or streamID, use `trackingData(streamID:)` to retrieve the most
    /// appropriate VTracking instance.
    func streamItemPointerForStandloneStreamItem() -> VStreamItemPointer? {
        return self.streamItemPointer(forStreamID: nil)
    }
    
    private func streamItemPointer(forStreamID streamID: String?) -> VStreamItemPointer? {
        guard let streamItemPointers = self.valueForKey("streamItemPointersInSream") as? Set<VStreamItemPointer> else {
            return nil
        }
        let filter: VStreamItemPointer->Bool
        if let streamID = streamID {
            filter = { $0.streamParent?.remoteId == streamID }
        
        } else {
            // If no `streamID` was provided, find an "empty" VStreamItemPointer,
            // i.e. one that points to a VStreamItem but has no associated stream- or marqueeParent.
            // This is made available for calling code that has no reference to a stream,
            // such as a deeplinked sequence or the lightweight content view sequence.
            filter = { $0.streamParent == nil && $0.marqueeParent == nil }
        }
        
        let matchingStreamItemPointers = streamItemPointers.filter(filter)
        guard let streamItemPointer = matchingStreamItemPointers.first else {
            return nil
        }
        return streamItemPointer
    }
}
