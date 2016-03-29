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
    
    func interstitialViewController(alert alert: Alert) -> InterstitialViewController? {
        switch alert.alertType {
            
        case .LevelUp:
            let tempalteValue = self.templateValueOfType(LevelUpViewController.self, forKey: "levelUpScreen")
            if let viewController = tempalteValue as? LevelUpViewController {
                viewController.alert = alert
                return viewController
            }
        
        case .StatusUpdate, .Achievement:
            let templateValue = templateValueOfType(InterstitialAlertViewController.self, forKey: "statusUpdateScreen")
            if let imageAlertVC = templateValue as? InterstitialAlertViewController {
                imageAlertVC.alert = alert
                return imageAlertVC
            }
        }
        return nil
    }
}
