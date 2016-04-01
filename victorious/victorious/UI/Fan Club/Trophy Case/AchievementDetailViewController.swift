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
    
    @IBOutlet private weak var semiTransparentBackgroundButton: UIButton!
    @IBOutlet private weak var achievementTitleLabel: UILabel!
    @IBOutlet private weak var achievementDetailLabel: UILabel!
    @IBOutlet private weak var confirmationButton: UIButton! {
        didSet {
            confirmationButton.setTitle(NSLocalizedString("Dismiss Alert", comment: ""), forState: .Normal)
        }
    }
    @IBOutlet private weak var alertView: UIView! {
        didSet {
            alertView.layer.cornerRadius = 10.0
        }
    }
    
    var dependencyManager: VDependencyManager?
    var achievement: Achievement?
    
    private struct AnimationConstants {
        static let initialAlertScale: CGFloat = 1.2
        static let alertFadeInAnimationTime: NSTimeInterval = 0.35
        static let backgroundButtonAlpha: CGFloat = 0.7
    }
    
    //MARK: - Factory Functions
    
    static func newAchievementDetailViewControllerWithDependencyManager(dependencyManager: VDependencyManager, achievement: Achievement) -> AchievementDetailViewController {
        let detailViewController: AchievementDetailViewController = AchievementDetailViewController.v_fromStoryboard(StringFromClass(TrophyCaseViewController), identifier: StringFromClass(AchievementDetailViewController))
        
        detailViewController.dependencyManager = dependencyManager
        detailViewController.achievement = achievement
        
        return detailViewController
    }
    
    //MARK: - View Controller Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeAlertViewBeforeAnimation()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        showAlertViewWithAnimation()
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return .Portrait
    }
    
    //MARK: - User Interactions
    
    @IBAction private func dismiss(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    //MARK: - Private Functions
    
    private func initializeAlertViewBeforeAnimation() {
        if let dependencyManager = dependencyManager {
            confirmationButton.backgroundColor = dependencyManager.colorForKey(VDependencyManagerAccentColorKey)
        }
        if let achievement = achievement {
            achievementTitleLabel.text = achievement.title
            achievementDetailLabel.text = achievement.detailedDescription
        }
        
        alertView.transform = CGAffineTransformMakeScale(AnimationConstants.initialAlertScale, AnimationConstants.initialAlertScale )
        alertView.alpha = 0.0
        semiTransparentBackgroundButton.alpha = 0.0
    }
    
    private func showAlertViewWithAnimation() {
        UIView.animateWithDuration(AnimationConstants.alertFadeInAnimationTime,
            delay: 0.0,
            usingSpringWithDamping: 1.0,
            initialSpringVelocity: 0.0,
            options: [],
            animations: {
                self.alertView.transform = CGAffineTransformIdentity
                self.alertView.alpha = 1.0
                self.semiTransparentBackgroundButton.alpha = AnimationConstants.backgroundButtonAlpha
            },
            completion: nil
        )
    }
}
