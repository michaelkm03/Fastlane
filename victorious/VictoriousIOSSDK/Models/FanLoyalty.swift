//
//  FanLoyalty.swift
//  victorious
//
//  Created by Tian Lan on 11/9/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation

public struct FanLoyalty {
    public let points: Int?
    public let level: Int
    public let progress: Int
    public let tier: String?
    public let name: String?
}

extension FanLoyalty {
    public init?(json: JSON) {

        guard let level = json["level"].int,
            let progress = json["progress"].int else {
                return nil
        }
        self.level = level
        self.progress = progress
        
        self.points = json["points"].int
        self.name = json["name"].string
        self.tier = json["tier"].string
    }
}
