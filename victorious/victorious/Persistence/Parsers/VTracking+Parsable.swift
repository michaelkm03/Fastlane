//
//  VTracking+Parsable.swift
//  victorious
//
//  Created by Patrick Lynch on 11/18/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

extension VTracking: PersistenceParsable {
    
    func populate( fromSourceModel tracking: TrackingModel ) {
        id                  = tracking.id
        cellClick           = tracking.trackingURLsForKey(.cellClick) ?? cellClick
        cellView            = tracking.trackingURLsForKey(.cellView) ?? cellView
        cellLoad            = tracking.trackingURLsForKey(.cellLoad) ?? cellLoad
        share               = tracking.trackingURLsForKey(.share) ?? share
        videoComplete100    = tracking.trackingURLsForKey(.videoComplete100) ?? videoComplete100
        videoComplete25     = tracking.trackingURLsForKey(.videoComplete25) ?? videoComplete25
        videoComplete50     = tracking.trackingURLsForKey(.videoComplete50) ?? videoComplete50
        videoComplete75     = tracking.trackingURLsForKey(.videoComplete75) ?? videoComplete75
        videoError          = tracking.trackingURLsForKey(.videoError) ?? videoError
        videoSkip           = tracking.trackingURLsForKey(.videoSkip) ?? videoSkip
        videoStall          = tracking.trackingURLsForKey(.videoStall) ?? videoStall
        viewStart           = tracking.trackingURLsForKey(.viewStart) ?? viewStart
        viewStop            = tracking.trackingURLsForKey(.viewStop) ?? viewStop
        stageView           = tracking.trackingURLsForKey(.stageView) ?? stageView
    }
}
