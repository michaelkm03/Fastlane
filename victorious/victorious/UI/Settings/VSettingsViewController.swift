//
//  SettingsViewController.swift
//  victorious
//
//  Created by Jarod Long on 8/17/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

extension VSettingsViewController: AccessoryScreenContainer {
    // MARK: - Objective-C compatibility
    
    func addAccessoryScreens() {
        addAccessoryScreens(to: navigationItem, from: dependencyManager)
    }
}
