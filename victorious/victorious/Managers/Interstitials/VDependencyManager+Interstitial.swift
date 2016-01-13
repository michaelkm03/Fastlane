//
//  VDependencyManager+Interstitial.swift
//  victorious
//
//  Created by Cody Kolodziejzyk on 9/9/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

extension VDependencyManager {
    
    func something() {
        
    }
    
    func interstitialViewController(alert alert: Alert) -> InterstitialViewController? {
        switch alert.alertType {
            
        case .LevelUp:
            let tempalteValue = self.templateValueOfType(LevelUpViewController.self, forKey: "levelUpScreen")
            if let viewController = tempalteValue as? LevelUpViewController {
                viewController.alert = alert
                return viewController
            }
            
        case .Achievement:
            let templateValue = self.templateValueOfType(AchievementViewController.self, forKey: "achievementScreen")
            if let achievementVC = templateValue as? AchievementViewController {
                achievementVC.alert = alert
                return achievementVC
            }
        }
        
        return nil
    }
}
