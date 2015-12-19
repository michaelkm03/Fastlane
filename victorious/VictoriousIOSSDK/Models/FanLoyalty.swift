//
//  FanLoyalty.swift
//  victorious
//
//  Created by Tian Lan on 11/9/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import SwiftyJSON

public struct FanLoyalty {
    public let points: Int64
    public let level: Int64
    public let progress: Int64
    public let tier: String?
    public let name: String?
}

extension FanLoyalty {
    public init?(json: JSON) {
        guard let level = json["level"].int64,
            let progress = json["progress"].int64 else {
                return nil
        }
        self.level = level
        self.progress = progress
        
        self.points = json["points"].int64Value
        self.name = json["name"].string
        self.tier = json["tier"].string
    }
}
