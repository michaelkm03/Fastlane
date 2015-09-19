//
//  AchievementInterstitial.swift
//  victorious
//
//  Created by Cody Kolodziejzyk on 9/18/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation

/// An interstitial that represents the achievement screen
struct AchievementInterstitial: Interstitial {
    
    let remoteID: Int
    let level: String
    let progressPercentage: Int
    let title: String
    let description: String
    let icon: NSURL
    
    init(remoteID: Int, level: String, progressPercentage: Int, title: String, description: String, icon: NSURL) {
        self.remoteID = remoteID
        self.level = level
        self.progressPercentage = progressPercentage
        self.title = title
        self.description = description
        self.icon = icon
    }
    
    func viewControllerToPresent(dependencyManager dependencyManager: VDependencyManager) -> InterstitialViewController? {
        if let levelUpVC = dependencyManager.levelUpViewController(self) as? InterstitialViewController {
            return levelUpVC
        }
        
        return nil
    }
}

extension VDependencyManager {
    
    func levelUpViewController(levelUpInterstitial: LevelUpInterstitial) -> LevelUpViewController? {
        if let levelUpVC = self.templateValueOfType(LevelUpViewController.self, forKey: "levelUpScreen") as? LevelUpViewController {
            levelUpVC.levelUpInterstitial = levelUpInterstitial
            return levelUpVC
        }
        
        return nil
    }
}