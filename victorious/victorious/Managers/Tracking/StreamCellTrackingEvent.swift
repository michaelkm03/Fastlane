//
//  StreamCellTrackingEvent.swift
//  victorious
//
//  Created by Cody Kolodziejzyk on 8/4/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import Foundation

@objc class StreamCellTrackingEvent : NSObject {
    var streamItem: VStreamItem?
    var stream: VStream?
    var fromShelf = false
}