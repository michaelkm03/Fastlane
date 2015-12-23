//
//  MockTimingTracker.swift
//  victorious
//
//  Created by Patrick Lynch on 12/11/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
@testable import victorious

@objc class MockTimingTracker: NSObject, TimingTracker {
    
    var eventsEnded = [String]()
    var eventsStarted = [String]()
    
    @objc func resetAllEvents() {}
    
    @objc func resetEvent(type type: String) {}
    
    @objc func startEvent(type type: String, subtype: String?) {
        eventsStarted.append( type )
    }
    
    @objc func endEvent(type type: String, subtype: String?) {
        eventsEnded.append( type )
    }
}
