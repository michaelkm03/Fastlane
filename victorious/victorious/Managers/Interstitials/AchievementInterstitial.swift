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
    
    /// Creates a new achievement interstitial
    ///
    /// - parameter remoteID: Remote ID of the interstitial
    /// - parameter level: The level of the current user
    /// - parameter progressPercentage: The current user's progress towards the next level
    /// - parameter title: Title of the achievement
    /// - parameter description: Description of the achievement
    /// - parameter icon: An optional icon URL that can be used in the achievement interstitial's view controller. 
    /// If no URL is provided, no icon will be displayed
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
