//
//  Tracking.swift
//  victorious
//
//  Created by Patrick Lynch on 11/18/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation

public enum TrackingKey: String {
    case viewStart = "view_start"
    case viewStop = "view_stop"
    case videoComplete25 = "view_25_complete"
    case videoComplete50 = "view_50_complete"
    case videoComplete75 = "view_75_complete"
    case videoComplete100 = "view_100_complete"
    case videoError = "view_error"
    case videoStall = "view_stall"
    case videoSkip = "view_skip"
    case cellView = "cell_view"
    case cellClick = "cell_click"
    case cellLoad = "cell_load"
    case share = "share"
}

public protocol Tracking {
    func trackingURLsForKey(key: TrackingKey) -> [String]?
}

public struct TrackingModel: Tracking {
    private let trackingMap: [TrackingKey : [String]]?
    
    public func trackingURLsForKey(key: TrackingKey) -> [String]? {
        return trackingMap?[key]
    }
}

extension TrackingModel {
    init(json: JSON) {
        var map = [TrackingKey : [String]]()
        json.dictionary?.forEach() { key, value in
            if let trackingKey = TrackingKey(rawValue: key) {
                map[trackingKey] = value.arrayValue.flatMap { $0.string }
            }
        }
        trackingMap = map
    }
}
