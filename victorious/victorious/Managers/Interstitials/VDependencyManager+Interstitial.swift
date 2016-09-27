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
    func interstitialViewController(alert: Alert) -> Interstitial? {
        var interstitial: Interstitial?

        switch alert.type {
            case .statusUpdate, .achievement, .clientSideCreated:
                let templateValue = templateValueOfType(InterstitialAlertViewController.self, forKey: "statusUpdateScreen")
                if let imageAlertVC = templateValue as? InterstitialAlertViewController {
                    interstitial = imageAlertVC
                }
            case .toast:
                let templateValue = templateValueOfType(InterstitialToastViewController.self, forKey: "toastScreen")
                if let toastViewController = templateValue as? InterstitialToastViewController {
                    interstitial = toastViewController
                }
            case .reconnectingError:
                let templateValue = templateValueOfType(InterstitialToastViewController.self, forKey: "error.toast")
                if let toastViewController = templateValue as? InterstitialToastViewController {
                    interstitial = toastViewController
                }
        }
        interstitial?.alert = alert

        return interstitial
    }
}
