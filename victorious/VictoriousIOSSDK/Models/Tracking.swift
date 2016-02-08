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
    public let cellClick: [String]?
    public let cellView: [String]?
    public let videoComplete25: [String]?
    public let videoComplete50: [String]?
    public let videoComplete75: [String]?
    public let videoComplete100: [String]?
    public let viewStop: [String]?
    public let videoError: [String]?
    public let videoSkip: [String]?
    public let videoStall: [String]?
    public let viewStart: [String]?
    public let share: [String]?
}

extension Tracking {
    public init(json: JSON) {
        viewStart           = json["view-start"].array?.flatMap { $0.string }
        viewStop            = json["view-stop"].array?.flatMap { $0.string }
        videoComplete25     = json["view-25-complete"].array?.flatMap { $0.string }
        videoComplete50     = json["view-50-complete"].array?.flatMap { $0.string }
        videoComplete75     = json["view-75-complete"].array?.flatMap { $0.string }
        videoComplete100    = json["view-100-complete"].array?.flatMap { $0.string }
        videoError          = json["view-error"].array?.flatMap { $0.string }
        videoStall          = json["view-stall"].array?.flatMap { $0.string }
        videoSkip           = json["view-skip"].array?.flatMap { $0.string }
        cellView            = json["cell-view"].array?.flatMap { $0.string }
        cellClick           = json["cell-click"].array?.flatMap { $0.string }
        share               = json["share"].array?.flatMap { $0.string }
    }
}
