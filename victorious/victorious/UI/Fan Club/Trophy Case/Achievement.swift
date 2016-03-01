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
    private(set) var dependencyManager: VDependencyManager?
    var iconImageURL: NSURL? {
        return isUnlocked ? iconURL : lockedIconURL
    }
    
    private var iconURL: NSURL?
    private var lockedIconURL: NSURL?
    private var isUnlocked: Bool {
        guard let unlockedAchievementsIdentifiers = VCurrentUser.user()?.achievementsUnlocked as? [String] else {
            return false
        }
        return unlockedAchievementsIdentifiers.contains(identifier)
    }
    
    init(dependencyManager: VDependencyManager) {
        self.dependencyManager = dependencyManager
        self.identifier = dependencyManager.stringForKey("identifier")
        self.title = dependencyManager.stringForKey("title")
        self.detailedDescription = dependencyManager.stringForKey("description")
        self.displayOrder = dependencyManager.numberForKey("display_order").integerValue
        self.iconURL = dependencyManager.iconImageURLAtDesiredScaleForKey("assets")
        self.lockedIconURL = dependencyManager.iconImageURLAtDesiredScaleForKey("locked_icon")
    }
}

//TODO: Get rid of this extension and use image for key
extension VDependencyManager {
    func iconImageURLAtDesiredScaleForKey(key: String) -> NSURL? {
        guard let assets = self.arrayForKey(key) as? [NSDictionary] else {
                return nil
        }
        let assetAtDesiredScale = assets.filter { $0["scale"] as? Int == Int(UIScreen.mainScreen().scale) }.first
        
        if let imageURLString = assetAtDesiredScale?["imageUrl"] as? String {
            return NSURL(string: imageURLString)
        } else {
            return nil
        }
    }
}
