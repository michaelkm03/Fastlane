//
//  VStreamItem+Pointer.swift
//  victorious
//
//  Created by Patrick Lynch on 2/4/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

/// The extensions in this file provide helpers for the necessarily complex
/// relationship between VStream, VStreamItem and VStreamItemPointer.

extension VStream {
    
    /// Maps stream items (instance sof  StreamItemPointer) into an array of the VStreamItems to which they point
    var streamItems: [VStreamItem] {
        return self.streamItemPointers.flatMap { ($0 as? VStreamItemPointer)?.streamItem }
    }
    
    /// Maps marquee items (instance sof VStreamItemPointer) into an array of the VStreamItems to which they point
    var marqueeItems: [VStreamItem] {
        return self.marqueeItemPointers.flatMap { ($0 as? VStreamItemPointer)?.streamItem }
    }
    
    /// Filters the receiver's `streamItemPointers` for those whose `streamItem` is contained
    /// within the provided list of streamItemIDs.
    func streamItemPointersForStreamItemIDs(streamItemIDs: [String]) -> NSOrderedSet {
        let filteredPointers = streamItemIDs.flatMap { id in
            self.streamItemPointers.filter { pointer in
                pointer.streamItem.remoteId == id
            }.first
        }
        return NSOrderedSet(array: filteredPointers)
    }
}

extension VStreamItem {
    
    /// Provides a `VStreamItemPointer` for the receiver in the stream that corresponds
    /// to the provided `streamID`.  If the caller legimiately has no reference
    /// to a stream or streamID (such as a deeplinked sequence or the lightweight
    /// content view sequence), use `streamItemPointerForStandloneStreamItem` instead.
    func streamItemPointer(streamID streamID: String) -> VStreamItemPointer? {
        return self.streamItemPointerForStreamID(streamID)
    }
    
    /// Provides a `VStreamItemPointer` or the receiver as a stand alone stream item,
    // i.e. one that did not come from a stream or a marquee.  If the caller has a reference
    /// to a stream or streamID, use `streamItemPointer(streamID:)` to retrieve the most
    /// appropriate `VStreamItemPointer` instance.
    func streamItemPointerForStandloneStreamItem() -> VStreamItemPointer? {
        return self.streamItemPointerForStreamID(nil)
    }
    
    private func streamItemPointerForStreamID(streamID: String?) -> VStreamItemPointer? {
        guard let streamItemPointers = self.parentStreamItemPointers as? Set<VStreamItemPointer> else {
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
