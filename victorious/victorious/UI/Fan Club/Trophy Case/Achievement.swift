//
//  Achievement.swift
//  victorious
//
//  Created by Tian Lan on 2/26/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

@objc class Achievement: NSObject {
    
    let identifier: String
    let title: String
    let detailedDescription: String
    let displayOrder: Int
    private(set) var iconAssets: [NSURL]?
    private(set) var dependencyManager: VDependencyManager?
    
    init(dependencyManager: VDependencyManager) {
        self.dependencyManager = dependencyManager
        self.identifier = dependencyManager.stringForKey("identifier")
        self.title = dependencyManager.stringForKey("title")
        self.detailedDescription = dependencyManager.stringForKey("description")
        self.displayOrder = dependencyManager.numberForKey("display_order").integerValue
        if let assets = dependencyManager.arrayForKey("assets") as? [NSDictionary] {
            iconAssets = assets.flatMap { NSURL(string: ($0["imageUrl"] as? String)!) }
        }
    }
}
