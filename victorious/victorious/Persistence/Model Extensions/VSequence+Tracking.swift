//
//  VSequence+Tracking.swift
//  victorious
//
//  Created by Patrick Lynch on 2/4/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

extension VSequence {
    
    /// Provides a `VTracking` object configured specific to the sequence's place in the stream
    /// that corresponds to the provided `streamID`.
    func trackingData(streamID streamID: String) -> VTracking? {
        guard let streamChildren = self.valueForKey("streamChildrenInSream") as? Set<VStreamChild> else {
            return nil
        }
        let matchingStreamChildren = streamChildren.filter { $0.streamParent.remoteId == streamID }
        guard let streamChild = matchingStreamChildren.first else {
            return nil
        }
        return streamChild.tracking
    }
    
    /// Provides a `VTracking` object for tracking code that has no stream context,
    /// such as a deeplinked sequence or the lightweight content view sequence.  If there is
    /// `VStream` instance with a valid `remoteId` for the sequence, please use `trackingData(streamID:)`
    /// instead of this method.
    func trackingWithoutStreamData() -> VTracking? {
        guard let streamChildren = self.valueForKey("streamChildrenInSream") as? Set<VStreamChild> else {
            return nil
        }
        let matchingStreamChildren = streamChildren .filter { $0.streamParent == nil && $0.marqueeParent == nil }
        guard let streamChild = matchingStreamChildren.first else {
            return nil
        }
        return streamChild.tracking
    }
}
