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
    public let level: Int
    public let progress: Int
}

extension FanLoyalty {
    public init?(json: JSON) {
        guard let points = json["points"].int64,
            let level = json["level"].int,
            let progress = json["progress"].int else {
                return nil
        }
        self.points = points
        self.level = level
        self.progress = progress
    }
}
