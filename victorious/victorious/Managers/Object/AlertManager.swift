//
//  AlertManager.swift
//  victorious
//
//  Created by Cody Kolodziejzyk on 9/8/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import Foundation

class AlertManager {
    
    static let sharedInstance = AlertManager()
    
    private let alertWindow: UIWindow
    
    init() {
        alertWindow = UIWindow(frame: UIScreen.mainScreen().bounds)
        alertWindow.hidden = true
        alertWindow.backgroundColor = UIColor.whiteColor()
        alertWindow.windowLevel = UIWindowLevelAlert
    }
    
    private var registeredAlerts = Set<Alert>()
    
    func registerAlerts(alerts: [Alert]) {
        for alert in alerts {
            if !registeredAlerts.contains(alert) {
                registeredAlerts.insert(alert)
                showAlert()
            }
        }
    }
    
    private func showAlert() {
        if let levelUpVC = UIStoryboard(name: "LevelUpScreen", bundle: NSBundle.mainBundle()).instantiateInitialViewController() as? LevelUpViewController {
            levelUpVC.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
//            alertWindow.rootViewController?.presentViewController(levelUpVC, animated: true, completion: nil)
            self.alertWindow.hidden = false
            self.alertWindow.makeKeyAndVisible()
        }
    }
}