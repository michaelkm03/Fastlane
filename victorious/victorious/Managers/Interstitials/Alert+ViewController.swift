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
    
    func viewController(dependencyManager dependencyManager: VDependencyManager) -> InterstitialViewController? {
        switch self.alertType {
            
        case .LevelUp:
            let tempalteValue = dependencyManager.templateValueOfType(LevelUpViewController.self, forKey: "levelUpScreen")
            if let viewController = tempalteValue as? LevelUpViewController {
                viewController.alert = self
                return viewController
            }
            
        case .Achievement:
            let templateValue = dependencyManager.templateValueOfType(AchievementViewController.self, forKey: "achievementScreen")
            if let achievementVC = templateValue as? AchievementViewController {
                achievementVC.alert = self
                return achievementVC
            }
        }
        
        return nil
    }
}
