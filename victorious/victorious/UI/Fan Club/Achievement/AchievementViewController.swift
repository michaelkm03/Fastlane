//
//  AchievementViewController.swift
//  victorious
//
//  Created by Cody Kolodziejzyk on 9/18/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation

class AchievementViewController: UIViewController, InterstitialViewController {
    
    let achievementAnimator = AchievementAnimator()
    let containerView = UIView()
    
    // MARK: - Public Properties
    
    var achievementInterstitial: AchievementInterstitial! {
        didSet {
            if let achievementInterstitial = achievementInterstitial {
                // TODO: customize
            }
        }
    }
    
    var dependencyManager: VDependencyManager! {
        didSet {
            if let dependencyManager = dependencyManager {
                // TODO: customize
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.clearColor()
        layoutContent()
    }
    
    private func layoutContent() {
        view.addSubview(containerView)
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[container(100)]|", options: [], metrics: nil, views: ["container" : containerView]))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[container]|", options: [], metrics: nil, views: ["container" : containerView]))
    }
    
    // MARK: Interstitial View Controller
    
    weak var interstitialDelegate: InterstitialViewControllerDelegate?
    
    func presentationAnimator() -> UIViewControllerAnimatedTransitioning {
        return achievementAnimator
    }
    
    func dismissalAnimator() -> UIViewControllerAnimatedTransitioning {
        achievementAnimator.isDismissal = true
        return achievementAnimator
    }
}