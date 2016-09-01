//
//  Tracking.swift
//  victorious
//
//  Created by Patrick Lynch on 11/18/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation

public enum ViewTrackingKey: String {
    case cellView = "cell_view"
    case cellClick = "cell_click"
    case cellLoad = "cell_load"
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
    var id: String { get }
    func trackingURLsForKey(key: ViewTrackingKey) -> [String]?
}

public struct Tracking: TrackingModel {
    public let id: String
    
    private let trackingMap: [String : [String]]?
    
    public func trackingURLsForKey(key: ViewTrackingKey) -> [String]? {
        return trackingMap?[key.rawValue]
    }
}

extension Tracking {
    init(json: JSON) {
        var map = [String : [String]]()
        var id = ""
        json.dictionary?.forEach() { key, value in
            if ViewTrackingKey(rawValue: key) != nil {
                let urlStrings = value.arrayValue.flatMap { $0.string }
                map[key] = urlStrings
                if id != "" {
                    id += ","
                }
                // Create id by appending hashes of strings instead of full strings to save space
                id += "\(key.hash)"
                for urlString in urlStrings {
                    id += "\(urlString.hash)"
                }
            }
        }
        self.id = id
        trackingMap = map
    }
}
