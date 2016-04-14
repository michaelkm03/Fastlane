//
//  TestAlertsViewController.swift
//  victorious
//
//  Created by Cody Kolodziejzyk on 9/24/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import UIKit
import Foundation

class TestAlertsViewController: UITableViewController {
    
    private enum TestAlertIndex: Int {
        case levelUp = 0
        case achievement = 1
        case statusUpdate = 2
        case toast = 3
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAtIndexPath: indexPath)
        cell.textLabel?.font = VThemeManager.sharedThemeManager().themedFontForKey(kVHeading3Font)
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        guard let index = TestAlertIndex(rawValue: indexPath.row) else {
            assertionFailure("Unknown type of test alert registered")
            return
        }
        
        switch index {
        case .levelUp:
            InterstitialManager.sharedInstance.debug_registerTestLevelUpAlert()
        case .achievement:
            InterstitialManager.sharedInstance.debug_registerTestAchievementAlert()
        case .statusUpdate:
            InterstitialManager.sharedInstance.debug_registerTestStatusUpdateAlert()
        case .toast:
            InterstitialManager.sharedInstance.debug_registerTestToastAlert()
        }
    }
    
    override func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return NSLocalizedString("TestAlertsViewControllerFooter", comment: "")
    }
}
