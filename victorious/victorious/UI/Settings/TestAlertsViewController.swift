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
    
    fileprivate enum TestAlertIndex: Int {
        case achievement = 0
        case statusUpdate = 1
        case toast = 2
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        cell.textLabel?.font = VThemeManager.shared().themedFont(forKey: kVHeading3Font)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let index = TestAlertIndex(rawValue: (indexPath as NSIndexPath).row) else {
            assertionFailure("Unknown type of test alert registered")
            return
        }
        
        switch index {
            case .achievement:
                InterstitialManager.sharedInstance.debug_registerTestAchievementAlert()
            case .statusUpdate:
                InterstitialManager.sharedInstance.debug_registerTestStatusUpdateAlert()
            case .toast:
                InterstitialManager.sharedInstance.debug_registerTestToastAlert()
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return NSLocalizedString("TestAlertsViewControllerFooter", comment: "")
    }
}
