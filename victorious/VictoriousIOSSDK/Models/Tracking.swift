//
//  Tracking.swift
//  victorious
//
//  Created by Patrick Lynch on 11/18/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation

public enum CellTrackingKey: String {
    case cellView = "cell_view"
    case cellClick = "cell_click"
    case cellLoad = "cell_load"
}

public enum ViewTrackingKey: String {
    case viewStart = "view_start"
    case viewStop = "view_stop"
    case videoComplete25 = "view_25_complete"
    case videoComplete50 = "view_50_complete"
    case videoComplete75 = "view_75_complete"
    case videoComplete100 = "view_100_complete"
    case videoError = "view_error"
    case videoStall = "view_stall"
    case videoSkip = "view_skip"
    case share = "share"
}

public protocol TrackingModel {
    func trackingURLsForKey(key: CellTrackingKey) -> [String]?
    func trackingURLsForKey(key: ViewTrackingKey) -> [String]?
}

public struct Tracking: TrackingModel {
    private let trackingMap: [String : [String]]?
    
    public func trackingURLsForKey(key: CellTrackingKey) -> [String]? {
        return trackingMap?[key.rawValue]
    }
    
    public func trackingURLsForKey(key: ViewTrackingKey) -> [String]? {
        return trackingMap?[key.rawValue]
    }
}

extension Tracking {
    init(json: JSON) {
        var map = [String : [String]]()
        json.dictionary?.forEach() { key, value in
            if
                CellTrackingKey(rawValue: key) != nil ||
                ViewTrackingKey(rawValue: key) != nil
            {
                map[key] = value.arrayValue.flatMap { $0.string }
            }
        }
        trackingMap = map
    }
}
