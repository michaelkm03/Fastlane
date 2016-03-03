//
//  AchievementDetailViewController.swift
//  victorious
//
//  Created by Tian Lan on 2/29/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation
import UIKit

class AchievementDetailViewController: UIViewController {
    
    @IBOutlet private weak var dismissButton: UIButton!
    @IBOutlet private weak var achievementTitleLabel: UILabel!
    @IBOutlet private weak var achievementDetailLabel: UILabel!
    @IBOutlet private weak var confirmationButton: UIButton! {
        didSet {
            confirmationButton.setTitle(NSLocalizedString("Dismiss Alert", comment: ""), forState: .Normal)
        }
    }
    @IBOutlet weak var alertView: UIView! {
        didSet {
            alertView.layer.cornerRadius = 10.0
        }
    }
    
    var dependencyManager: VDependencyManager?
    var achievement: Achievement?
    
    static func makeAchievementDetailViewControllerWithDependencyManager(dependencyManager: VDependencyManager, achievement: Achievement) -> AchievementDetailViewController {
        let detailViewController: AchievementDetailViewController = AchievementDetailViewController.v_fromStoryboard(StringFromClass(TrophyCaseViewController), identifier: StringFromClass(AchievementDetailViewController))
        
        detailViewController.dependencyManager = dependencyManager
        detailViewController.achievement = achievement
        
        return detailViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let dependencyManager = dependencyManager {
            confirmationButton.backgroundColor = dependencyManager.colorForKey(VDependencyManagerAccentColorKey)
        }
        if let achievement = achievement {
            achievementTitleLabel.text = achievement.title
            achievementDetailLabel.text = achievement.detailedDescription
        }
    }
    
    @IBAction func dismiss(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}
