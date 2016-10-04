//
//  TimingTracker.swift
//  victorious
//
//  Created by Patrick Lynch on 12/11/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation

/// Defines an object that can execute some basic application timing tracking functions
@objc protocol TimingTracker {
    
    /// Removes all events that have been started so that they will not be tracked
    /// event if `endEvent(type:subtype:)` is called with a matching event type.
    /// This eseentially allows calling code to "cancel" timing and tracking an event type.
    func resetAllEvents()
    
    /// Removes an event with the provided type that have been started so that they will not be tracked
    /// event if `endEvent(type:subtype:)` is called with a matching event type.
    /// This eseentially allows calling code to "cancel" timing and tracking an event type.
    func resetEvent(type: String)
    
    /// Begins a timer for an event with the provided `type` value.
    func startEvent(type: String, subtype: String?)
    
    /// Finishes timing the duration an event with the provided `type` value and tracks
    /// it according to its own concrete tracking routine, such as configuring and
    /// sending a URL request.
    func endEvent(type: String, subtype: String?)
}
