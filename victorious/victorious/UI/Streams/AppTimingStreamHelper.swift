//
//  AppTimingStreamHelper.swift
//  victorious
//
//  Created by Patrick Lynch on 12/11/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation

private var token: dispatch_once_t = 0

class AppTimingStreamHelper: NSObject {
    
    private let timingTracker: TimingTracker
    private let streamId: String?
    
    init( streamId: String?, timingTracker: TimingTracker ) {
        self.streamId = streamId
        self.timingTracker = timingTracker
    }
    
    func startStreamLoadAppTimingEvents(pageType pageType: VPageType) {
        
        if pageType == .First {
            timingTracker.startEvent( type: VAppTimingEventTypeStreamRefresh, subtype: streamId )
            
        } else {
            timingTracker.startEvent( type: VAppTimingEventTypeStreamLoad, subtype: streamId )
        }
    }
    
    func endStreamLoadAppTimingEvents(pageType pageType: VPageType) {
        
        if pageType == .First {
            timingTracker.endEvent( type: VAppTimingEventTypeStreamRefresh, subtype: streamId)
            
            dispatch_once(&token) {
                self.timingTracker.endEvent( type: VAppTimingEventTypeAppStart, subtype: self.streamId )
            }
            
        } else {
            timingTracker.endEvent( type: VAppTimingEventTypeStreamLoad, subtype: streamId)
        }
    }
}
