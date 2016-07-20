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
    public let level: Int?
    public let progress: Int?
    public let tier: String?
    public let name: String?
    public let achievementsUnlocked: [String]
}

extension FanLoyalty {
    public init(json: JSON) {
        self.level = json["level"].int
        self.progress = json["progress"].int
        
        self.points = json["points"].int
        self.name = json["name"].string
        self.tier = json["tier"].string
        self.achievementsUnlocked = json["achievements_unlocked"].arrayValue.flatMap { $0.stringValue }
    }
    
    public init(level: Int, progress: Int, points: Int? = nil, name: String? = nil, tier: String? = nil, achievementsUnlocked: [String] = []) {
        self.level = level
        self.progress = progress
        
        self.points = points
        self.name = name
        self.tier = tier
        self.achievementsUnlocked = achievementsUnlocked
    }
}
