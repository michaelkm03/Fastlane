//
//  Achievement.swift
//  victorious
//
//  Created by Tian Lan on 2/26/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

@objc class Achievement: NSObject {
    
    let title: String
    let detailedDescription: String
    let displayOrder: Int
    
    var iconImage: UIImage? {
        return isUnlocked ? unlockedIconImage : lockedIconImage
    }
    var isUnlocked: Bool {
        guard let unlockedAchievementsIdentifiers = VCurrentUser.user()?.achievementsUnlocked as? [String] else {
            return false
        }
        return unlockedAchievementsIdentifiers.contains(identifier)
    }
    
    private let dependencyManager: VDependencyManager
    private let identifier: String
    private let unlockedIconImage: UIImage
    private let lockedIconImage: UIImage
    
    init?(dependencyManager: VDependencyManager) {
        self.dependencyManager = dependencyManager
        
        guard let identifier = dependencyManager.achievementIdentifer,
            let title = dependencyManager.achievementTitle,
            let description = dependencyManager.achievementDescription,
            let displayOrder = dependencyManager.achievementDisplayOrder,
            let unlockedIconImage = dependencyManager.achievementUnlockedIconImage,
            let lockedIconImage = dependencyManager.achievementLockedIconImage else {
                /// Compiler limitation: Have to manually initialize these before returning nil. Remove this in Swift 2.2
                self.identifier = ""
                self.title = ""
                self.detailedDescription = ""
                self.displayOrder = -1
                self.unlockedIconImage = UIImage()
                self.lockedIconImage = UIImage()
                
                super.init()
                return nil
        }
        
        self.identifier = identifier
        self.title = title
        self.detailedDescription = description
        self.displayOrder = displayOrder
        self.unlockedIconImage = unlockedIconImage
        self.lockedIconImage = lockedIconImage
        
        super.init()
    }
}

private extension VDependencyManager {
    
    var achievementIdentifer: String? {
        return stringForKey("identifier")
    }
    
    var achievementTitle: String? {
        return stringForKey("title")
    }
    
    var achievementDescription: String? {
        return stringForKey("description")
    }
    
    var achievementDisplayOrder: Int? {
        return numberForKey("display_order").integerValue
    }
    
    var achievementUnlockedIconImage: UIImage? {
        return imageForKey("assets")
    }
    
    var achievementLockedIconImage: UIImage? {
        return imageForKey("locked_icon")
    }
}
