//
//  AchievementViewController.swift
//  victorious
//
//  Created by Cody Kolodziejzyk on 9/18/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation

class AchievementViewController: UIViewController, InterstitialViewController {
    
    struct AnimationConstants {
        static let presentationDuration = 0.4
        static let dismissalDuration = 0.2
    }
    
    let achievementAnimator = AchievementAnimator()
    let containerView = UIView()
    let dismissButton = UIButton(type: .Custom)
    let iconImageView = UIImageView()
    let titleLabel = UILabel()
    let descriptionLabel = UILabel()
    
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
        containerView.backgroundColor = UIColor.whiteColor()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addConstraint(NSLayoutConstraint(item: containerView, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 300))
        containerView.addConstraint(NSLayoutConstraint(item: containerView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 300))
        view.addConstraint(NSLayoutConstraint(item: containerView, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0))
         view.addConstraint(NSLayoutConstraint(item: containerView, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0))
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