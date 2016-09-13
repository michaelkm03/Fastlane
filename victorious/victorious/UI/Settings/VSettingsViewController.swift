//
//  VSettingsViewController.swift
//  victorious
//
//  Created by Jarod Long on 9/8/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

extension VSettingsViewController {
    func queueLogoutOperation() {
        LogoutOperation(dependencyManager: dependencyManager ?? nil).queue()
    }
}
