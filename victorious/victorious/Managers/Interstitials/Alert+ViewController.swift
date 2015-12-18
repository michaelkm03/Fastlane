//
//  LevelUpInterstitial.swift
//  victorious
//
//  Created by Cody Kolodziejzyk on 9/9/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

extension Alert {
    
    func viewControllerToPresent(dependencyManager dependencyManager: VDependencyManager) -> InterstitialViewController? {
        switch self.alertType {
        case .LevelUp:
            if let levelUpVC = dependencyManager.levelUpViewController(alert: self) as? InterstitialViewController {
                return levelUpVC
            }
        case .Achievement:
            if let achievementVC = dependencyManager.achievementViewController(alert: self) as? InterstitialViewController {
                return achievementVC
            }
        }
        return nil
    }
}

private extension VDependencyManager {
    
    func achievementViewController(alert alert: Alert) -> AchievementViewController? {
        if let achievementVC = self.templateValueOfType(AchievementViewController.self, forKey: "achievementScreen") as? AchievementViewController {
            achievementVC.alert = alert
            return achievementVC
        }
        
        return nil
    }
    
    func levelUpViewController(alert alert: Alert) -> LevelUpViewController? {
        if let levelUpVC = self.templateValueOfType(LevelUpViewController.self, forKey: "levelUpScreen") as? LevelUpViewController {
            levelUpVC.alert = alert
            return levelUpVC
        }
        
        return nil
    }
}