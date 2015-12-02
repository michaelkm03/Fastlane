//
//  Tracking.swift
//  victorious
//
//  Created by Patrick Lynch on 11/18/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import SwiftyJSON

public struct Tracking {
    public let cellClick: [String]
    public let cellView: [String]
    public let videoComplete25: [String]
    public let videoComplete50: [String]
    public let videoComplete75: [String]
    public let videoComplete100: [String]
    public let viewStop: [String]
    public let videoError: [String]
    public let videoSkip: [String]
    public let videoStall: [String]
    public let viewStart: [String]
    public let share: [String]
}

extension Tracking {
    public init(json: JSON) {
        viewStart           = json["view-start"].arrayValue.map { $0.stringValue }
        viewStop            = json["view-stop"].arrayValue.map { $0.stringValue }
        videoComplete25     = json["view-25-complete"].arrayValue.map { $0.stringValue }
        videoComplete50     = json["view-50-complete"].arrayValue.map { $0.stringValue }
        videoComplete75     = json["view-75-complete"].arrayValue.map { $0.stringValue }
        videoComplete100    = json["view-100-complete"].arrayValue.map { $0.stringValue }
        videoError          = json["view-error"].arrayValue.map { $0.stringValue }
        videoStall          = json["view-stall"].arrayValue.map { $0.stringValue }
        videoSkip           = json["view-skip"].arrayValue.map { $0.stringValue }
        cellView            = json["cell-view"].arrayValue.map { $0.stringValue }
        cellClick           = json["cell-click"].arrayValue.map { $0.stringValue }
        share               = json["share"].arrayValue.map { $0.stringValue }
    }
}
