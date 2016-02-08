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
    
    func populate( fromSourceModel tracking: Tracking ) {
        cellClick           = tracking.cellClick ?? cellClick
        cellView            = tracking.cellView ?? cellView
        share               = tracking.share ?? share
        videoComplete100    = tracking.videoComplete100 ?? videoComplete100
        videoComplete25     = tracking.videoComplete25 ?? videoComplete25
        videoComplete50     = tracking.videoComplete50 ?? videoComplete50
        videoComplete75     = tracking.videoComplete75 ?? videoComplete75
        videoError          = tracking.videoError ?? videoError
        videoSkip           = tracking.videoSkip ?? videoSkip
        videoStall          = tracking.videoStall ?? videoStall
        viewStart           = tracking.viewStart ?? viewStart
        viewStop            = tracking.viewStop ?? viewStop
    }
}
