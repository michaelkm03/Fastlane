//
//  AchievementViewController.swift
//  victorious
//
//  Created by Cody Kolodziejzyk on 9/18/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation

private struct AchievementConstants {
    static let animatedBadgeKey = "animatedBadge"
}

class AchievementViewController: UIViewController, InterstitialViewController, VBackgroundContainer {
    
    struct AnimationConstants {
        static let presentationDuration = 0.4
        static let dismissalDuration = 0.2
        static let containerWidth: CGFloat = 292
        static let badgeAnimationTotalDuration = 2.0
    }
    
    private let achievementAnimator = AchievementAnimator()
    private let containerView = UIView()
    private let dismissButton = UIButton()
    private let iconImageView = UIImageView()
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private var animatedBadge: AnimatedBadgeView?
    
    private var hasAppeared = false
    
    // MARK: - Public Properties
    
    var achievementInterstitial: AchievementInterstitial! {
        didSet {
            if let achievementInterstitial = achievementInterstitial {
                descriptionLabel.text = achievementInterstitial.description
                titleLabel.text = achievementInterstitial.title
                iconImageView.setImageWithURL(achievementInterstitial.icon)
                
                animatedBadge?.levelNumberString = String(achievementInterstitial.level)
            }
        }
    }
    
    var dependencyManager: VDependencyManager! {
        didSet {
            if let dependencyManager = dependencyManager {
                titleLabel.font = dependencyManager.titleFont
                descriptionLabel.font = dependencyManager.descriptionFont
                dismissButton.backgroundColor = dependencyManager.dismissButtonColor
                dismissButton.setTitle(dependencyManager.dismissButtonTitle, forState: .Normal)
                dismissButton.setTitleColor(dependencyManager.dismissButtonTitleColor, forState: .Normal)
                dismissButton.setTitleColor(dependencyManager.dismissButtonTitleColor.colorWithAlphaComponent(0.5), forState: .Highlighted)
                dismissButton.titleLabel?.font = dependencyManager.dismissButtonTitleFont
                dependencyManager.addBackgroundToBackgroundHost(self)
                animatedBadge = dependencyManager.animatedBadge
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.clearColor()
        layoutContent()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if !hasAppeared {
            setToInitialState()
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if !hasAppeared {
            animateIn() { completed in
                let duration = AnimationConstants.badgeAnimationTotalDuration * (Double(self.achievementInterstitial.progressPercentage) / 100.0)
                self.animatedBadge?.animateProgress(duration, endPercentage: self.achievementInterstitial.progressPercentage)
            }
        }
    }
    
    private func layoutContent() {
        
        containerView.backgroundColor = UIColor.whiteColor()
        
        view.addSubview(containerView)
        containerView.backgroundColor = UIColor.whiteColor()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addConstraint(NSLayoutConstraint(item: containerView, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: AnimationConstants.containerWidth))
        view.addConstraint(NSLayoutConstraint(item: containerView, attribute: .CenterX, relatedBy: .Equal, toItem: view, attribute: .CenterX, multiplier: 1, constant: 0))
         view.addConstraint(NSLayoutConstraint(item: containerView, attribute: .CenterY, relatedBy: .Equal, toItem: view, attribute: .CenterY, multiplier: 1, constant: 0))
        
        containerView.addSubview(dismissButton)
        dismissButton.translatesAutoresizingMaskIntoConstraints = false
        dismissButton.addTarget(self, action: "pressedDismiss", forControlEvents: .TouchUpInside)
        containerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[button]|", options: [], metrics: nil, views: ["button" : dismissButton]))
        
        containerView.addSubview(iconImageView)
        iconImageView.contentMode = .ScaleAspectFit
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[icon]|", options: [], metrics: nil, views: ["icon" : iconImageView]))
        
        containerView.addSubview(descriptionLabel)
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.numberOfLines = 0
        descriptionLabel.backgroundColor = UIColor.clearColor()
        descriptionLabel.textAlignment = NSTextAlignment.Center
        descriptionLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
        containerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-60-[label]-60-|", options: [], metrics: nil, views: ["label" : descriptionLabel]))
        
        containerView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.numberOfLines = 0
        titleLabel.backgroundColor = UIColor.clearColor()
        titleLabel.textAlignment = NSTextAlignment.Center
        titleLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
        containerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-10-[label]-10-|", options: [], metrics: nil, views: ["label" : titleLabel]))
        
        var verticalConstraintString = ""
        var views: [String : UIView]
        
        if let animatedBadge = animatedBadge {
            animatedBadge.translatesAutoresizingMaskIntoConstraints = false
            containerView.addSubview(animatedBadge)
            verticalConstraintString = "V:|-23-[badgeView(70)]-29-[title]-20-[description][icon(135)][button(40)]|"
            views = ["badgeView" : animatedBadge, "button" : dismissButton, "icon" : iconImageView, "description" : descriptionLabel, "title" : titleLabel]
            
            animatedBadge.v_addWidthConstraint(60)
            containerView.v_addCenterHorizontallyConstraintsToSubview(animatedBadge)
        }
        else {
            verticalConstraintString = "V:|-23-[title]-20-[description][icon(135)][button(40)]|"
            views = ["button" : dismissButton, "icon" : iconImageView, "description" : descriptionLabel, "title" : titleLabel]
        }
        
        containerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(verticalConstraintString, options: [], metrics: nil, views: views))
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    /// MARK: Actions
    
    func pressedDismiss() {
        animateOut { (completed) in
            self.interstitialDelegate?.dismissInterstitial(self)
        }
    }
    
    /// MARK: Helpers
    
    private func animateIn(completion: ((Bool) -> Void)?) {
        
        UIView.animateWithDuration(0.6, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.4, options: .CurveEaseInOut, animations: {
            self.containerView.transform = CGAffineTransformIdentity
            }, completion: completion)
    }
    
    private func animateOut(completion: ((Bool) -> Void)?) {
        UIView.animateWithDuration(0.2, animations: { () in
            self.setToInitialState()
            }, completion: completion)
    }
    
    private func setToInitialState() {
        containerView.transform = CGAffineTransformMakeTranslation(0, self.view.bounds.height - containerView.bounds.origin.y)
    }
    
    /// MARK: Interstitial View Controller
    
    weak var interstitialDelegate: InterstitialViewControllerDelegate?
    
    func presentationAnimator() -> UIViewControllerAnimatedTransitioning {
        return achievementAnimator
    }
    
    func dismissalAnimator() -> UIViewControllerAnimatedTransitioning {
        achievementAnimator.isDismissal = true
        return achievementAnimator
    }
    
    /// MARK: Background
    
    func backgroundContainerView() -> UIView {
        return self.containerView
    }
}

private extension VDependencyManager {
    var dismissButtonColor: UIColor {
        return self.colorForKey(VDependencyManagerLinkColorKey)
    }
    
    var dismissButtonTitleFont: UIFont {
        return self.fontForKey(VDependencyManagerHeading4FontKey)
    }
    
    var dismissButtonTitleColor: UIColor {
        return self.colorForKey(VDependencyManagerContentTextColorKey)
    }
    
    var titleFont: UIFont {
        return self.fontForKey(VDependencyManagerHeading3FontKey)
    }
    
    var descriptionFont: UIFont {
        return self.fontForKey(VDependencyManagerParagraphFontKey)
    }
    
    var textColor: UIColor {
        return self.colorForKey(VDependencyManagerMainTextColorKey)
    }
    
    var dismissButtonTitle: String {
        return self.stringForKey("button.title")
    }
    
    var animatedBadge: AnimatedBadgeView? {
        
        // Initialize our animated badge view component
        guard let badgeView = self.templateValueOfType(AnimatedBadgeView.self, forKey: AchievementConstants.animatedBadgeKey) as? AnimatedBadgeView else {
            return nil
        }
        
        // Set our animated badge property
        badgeView.progressBarInset = 3
        badgeView.animatedBorderWidth = 3
        badgeView.cornerRadius = 4
        badgeView.levelStringLabel.font = UIFont(name: "OpenSans-Bold", size: 8)
        badgeView.levelNumberLabel.font = UIFont(name: "OpenSans-Bold", size: 18)
        return badgeView
    }
}
