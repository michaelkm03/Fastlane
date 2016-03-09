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
        self.identifier = dependencyManager.achievementIdentifer
        self.title = dependencyManager.achievementTitle
        self.detailedDescription = dependencyManager.achievementDescription
        self.displayOrder = dependencyManager.achievementDisplayOrder
        self.unlockedIconImage = dependencyManager.achievementUnlockedIconImage
        self.lockedIconImage = dependencyManager.achievementLockedIconImage
    }
}


private extension VDependencyManager {
    
    var achievementIdentifer: String {
        return stringForKey("identifier")
    }
    
    var achievementTitle: String {
        return stringForKey("title")
    }
    
    var achievementDescription: String {
        return stringForKey("description")
    }
    
    var achievementDisplayOrder: Int {
        return numberForKey("display_order").integerValue
    }
    
    var achievementUnlockedIconImage: UIImage {
        return imageForKey("assets")
    }
    
    var achievementLockedIconImage: UIImage {
        return imageForKey("locked_icon")
    }
}
