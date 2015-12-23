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
    let fanLoyalty: FanLoyalty?
    let title: String
    let description: String
    let icons: [NSURL]
    
    /// Creates a new achievement interstitial
    ///
    /// - parameter remoteID: Remote ID of the interstitial
    /// - parameter level: The level of the current user
    /// - parameter progressPercentage: The current user's progress towards the next level
    /// - parameter title: Title of the achievement
    /// - parameter description: Description of the achievement
    /// - parameter icons: An array of icon URLs.
    /// If no URL is provided, no icon will be displayed
    init(remoteID: Int, fanLoyalty: FanLoyalty?, title: String, description: String, icons: [NSURL]) {
        self.remoteID = remoteID
        self.fanLoyalty = fanLoyalty
        self.title = title
        self.description = description
        self.icons = icons
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
