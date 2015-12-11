//
//  ContentViewAppTimingHelper.swift
//  victorious
//
//  Created by Patrick Lynch on 12/11/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation

/// Represents the main endpoints to which content view must send a request after it is presented.
@objc enum ContentViewEndpoint: Int {
    case PollData
    case Comments
    case UserInfo
    case SequenceData
    
    static var AllCases: Set<ContentViewEndpoint> {
        return Set<ContentViewEndpoint>(arrayLiteral: .PollData, .Comments, .UserInfo, .SequenceData)
    }
}

/// An object that abstracts content view's app timing tracking requirements into something more convenient
class AppTimingContentHelper: NSObject {
    
    private let timingTracker: TimingTracker
    
    init( timingTracker: TimingTracker ) {
        self.timingTracker = timingTracker
    }
    
    private var completedEndpoints = Set<ContentViewEndpoint>()
    
    /// Signals the start of a session during which tracking of completed endpoints may occur.
    func start() {
        if completedEndpoints.count < ContentViewEndpoint.AllCases.count {
            timingTracker.startEvent(type: VAppTimingEventTypeContentViewLoad, subtype:nil)
        }
    }
    
    func reset() {
        completedEndpoints.removeAll()
    }
    
    /// Signals the completion of a request to the provided endpoint and executes any app timing tracking
    /// requirements.  Call this when the endpoint finishes loading, whether the request returned
    /// successfully or with an error.
    func setEndpointFinished( endpoint: ContentViewEndpoint ) {
        completedEndpoints.insert( endpoint )
        
        if completedEndpoints.count == ContentViewEndpoint.AllCases.count {
            timingTracker.endEvent(type: VAppTimingEventTypeContentViewLoad, subtype:nil)
        }
    }
}
