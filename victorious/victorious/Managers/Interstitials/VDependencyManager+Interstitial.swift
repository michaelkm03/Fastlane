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
    func interstitialViewController(alert alert: Alert) -> Interstitial? {
        var interstitial: Interstitial?

        switch alert.alertType {
            case .LevelUp:
                let tempalteValue = templateValueOfType(LevelUpViewController.self, forKey: "levelUpScreen")
                if let viewController = tempalteValue as? LevelUpViewController {
                    viewController.alert = alert
                    interstitial = viewController
                }
            case .StatusUpdate, .Achievement, .ClientSideCreated:
                let templateValue = templateValueOfType(InterstitialAlertViewController.self, forKey: "statusUpdateScreen")
                if let imageAlertVC = templateValue as? InterstitialAlertViewController {
                    imageAlertVC.alert = alert
                    interstitial = imageAlertVC
                }
            case .Toast:
                let templateValue = templateValueOfType(InterstitialToastViewController.self, forKey: "toastScreen")
                if let toastViewController = templateValue as? InterstitialToastViewController {
                    toastViewController.alert = alert
                    interstitial = toastViewController
                }
            case .WebSocketError:
                interstitial = nil
        }
        return interstitial
    }
}
