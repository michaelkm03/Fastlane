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
        cellClick           = tracking.cellClick
        cellView            = tracking.cellView
        videoComplete25     = tracking.videoComplete25
        videoComplete50     = tracking.videoComplete50
        videoComplete75     = tracking.videoComplete75
        videoComplete100    = tracking.videoComplete100
        viewStop            = tracking.viewStop
        videoError          = tracking.videoError
        videoSkip           = tracking.videoSkip
        videoStall          = tracking.videoStall
        viewStart           = tracking.viewStart
        share               = tracking.share
    }
}