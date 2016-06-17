//
//  ContentTracking.swift
//  victorious
//
//  Created by Sharif Ahmed on 6/17/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

public enum ViewTrackingKey: String {
    case cellView = "cell_view"
}

public struct ContentTracking {
    public let trackingMap: [ViewTrackingKey : [String]]?
    
    init(json: JSON) {
        var map = [ViewTrackingKey : [String]]()
        json.dictionary?.forEach() { key, value in
            if let trackingKey = ViewTrackingKey(rawValue: key) {
                map[trackingKey] = value.arrayValue.flatMap { $0.string }
            }
        }
        trackingMap = map
    }
}
