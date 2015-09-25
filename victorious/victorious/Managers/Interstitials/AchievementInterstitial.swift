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
    let level: Int
    let progressPercentage: Int
    let title: String
    let description: String
    let icon: NSURL?
    
    init(remoteID: Int, level: Int, progressPercentage: Int, title: String, description: String, icon: NSURL?) {
        self.remoteID = remoteID
        self.level = level
        self.progressPercentage = progressPercentage
        self.title = title
        self.description = description
        self.icon = icon
    }
    
    func viewControllerToPresent(dependencyManager dependencyManager: VDependencyManager) -> InterstitialViewController? {
        if let achievementVC = dependencyManager.achievementViewController(self) as? InterstitialViewController {
            return achievementVC
        }
        
        return nil
    }
}

private extension VDependencyManager {
    
    func achievementViewController(achievementInterstitial: AchievementInterstitial) -> AchievementViewController? {
        if let achievementVC = self.templateValueOfType(AchievementViewController.self, forKey: "achievementScreen") as? AchievementViewController {
            achievementVC.achievementInterstitial = achievementInterstitial
            return achievementVC
        }
        
        return nil
    }
}