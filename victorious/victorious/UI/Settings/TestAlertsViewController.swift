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
    
    private enum Indexes: Int {
        case LevelUp = 0, Achievement = 1
    }
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if indexPath.row == Indexes.LevelUp.rawValue {
            InterstitialManager.sharedInstance.registerTestLevelUpAlert()
        }
        else if indexPath.row == Indexes.Achievement.rawValue {
            InterstitialManager.sharedInstance.registerTestAchievementAlert()
        }
    }
}
