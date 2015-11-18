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
        viewStart           = json["view-start"].arrayValue.flatMap { String($0) }
        viewStop            = json["view-stop"].arrayValue.flatMap { String($0) }
        videoComplete25     = json["view-25-complete"].arrayValue.flatMap { String($0) }
        videoComplete50     = json["view-50-complete"].arrayValue.flatMap { String($0) }
        videoComplete75     = json["view-75-complete"].arrayValue.flatMap { String($0) }
        videoComplete100    = json["view-100-complete"].arrayValue.flatMap { String($0) }
        videoError          = json["view-error"].arrayValue.flatMap { String($0) }
        videoStall          = json["view-stall"].arrayValue.flatMap { String($0) }
        videoSkip           = json["view-skip"].arrayValue.flatMap { String($0) }
        cellView            = json["cell-view"].arrayValue.flatMap { String($0) }
        cellClick           = json["cell-click"].arrayValue.flatMap { String($0) }
        share               = json["share"].arrayValue.flatMap { String($0) }
    }
}
