//
//  VSequence+Tracking.swift
//  victorious
//
//  Created by Patrick Lynch on 2/4/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

extension VSequence {
    
    /// Provides a `VTracking` object most appropriate sequence in the context
    /// of the provided stream. If the caller legimiately has no reference to a
    /// stream or streamID (such as a deeplinked sequence or the lightweight content
    /// view sequence), use `trackingForStandloneSequence` instead.
    func trackingData(streamID streamID: String) -> VTracking? {
        guard let streamItemPointers = self.valueForKey("streamItemPointersInSream") as? Set<VStreamItemPointer> else {
            return nil
        }
        let matchingStreamItemPointerren = streamItemPointers.filter { $0.streamParent.remoteId == streamID }
        guard let streamPointer = matchingStreamItemPointerren.first else {
            return nil
        }
        return streamPointer.tracking
    }
    
    /// Provides a `VTracking` for standalone sequences, i.e. those that did
    /// not come from a stream or a marquee.  If the caller has a reference to
    /// a stream or streamID, use `trackingData(streamID:)` to retrieve the most
    /// appropriate VTracking instance.
    func trackingForStandaloneSequence() -> VTracking? {
        guard let streamItemPointers = self.valueForKey("streamItemPointersInSream") as? Set<VStreamItemPointer> else {
            return nil
        }
        let matchingStreamItemPointerren = streamItemPointers .filter { $0.streamParent == nil && $0.marqueeParent == nil }
        guard let streamPointer = matchingStreamItemPointerren.first else {
            return nil
        }
        return streamPointer.tracking
    }
}
