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
    let dependencyManager: VDependencyManager
    
    var iconImage: UIImage? {
        return isUnlocked ? unlockedIconImage : lockedIconImage
    }
    var isUnlocked: Bool {
        guard let unlockedAchievementsIdentifiers = VCurrentUser.user()?.achievementsUnlocked as? [String] else {
            return false
        }
        return unlockedAchievementsIdentifiers.contains(identifier)
    }
    
    private var unlockedIconImage: UIImage?
    private var lockedIconImage: UIImage?
    
    init(dependencyManager: VDependencyManager) {
        self.dependencyManager = dependencyManager
        self.identifier = dependencyManager.stringForKey("identifier")
        self.title = dependencyManager.stringForKey("title")
        self.detailedDescription = dependencyManager.stringForKey("description")
        self.displayOrder = dependencyManager.numberForKey("display_order").integerValue
        self.unlockedIconImage = dependencyManager.imageForKey("assets")
        self.lockedIconImage = dependencyManager.imageForKey("locked_icon")
    }
}
