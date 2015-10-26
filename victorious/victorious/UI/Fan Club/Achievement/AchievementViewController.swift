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
        static let presentationDuration = 0.5
        static let dismissalDuration = 0.3
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
    private let iconImageViewHeightConstant: CGFloat = 135.0
    
    private lazy var dismissalView: UIView = {
        let view = UIView()
        let tapGesture = UITapGestureRecognizer(target: self, action: "tappedBackground")
        view.addGestureRecognizer(tapGesture)
        return view
    }()
    
    private lazy var iconImageViewHeightConstraint: NSLayoutConstraint = {
        let iconImageViewHeightConstraint = NSLayoutConstraint(item: self.iconImageView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: self.iconImageViewHeightConstant)
        return iconImageViewHeightConstraint
    }()
    
    // MARK: - Public Properties
    
    var achievementInterstitial: AchievementInterstitial! {
        didSet {
            if let achievementInterstitial = achievementInterstitial {
                descriptionLabel.text = achievementInterstitial.description
                titleLabel.text = achievementInterstitial.title
                animatedBadge?.levelNumberString = String(achievementInterstitial.level)
                
                guard let iconURL = achievementInterstitial.icons.first where iconURL.absoluteString.characters.count > 0 else {
                    // In order to add space between the description label and the dismiss button
                    iconImageViewHeightConstraint.constant = 23
                    return
                }
                
                iconImageView.setImageWithURL(iconURL)
                iconImageViewHeightConstraint.constant = iconImageViewHeightConstant
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
    
    /// MARK: Actions
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        let duration = AnimationConstants.badgeAnimationTotalDuration * (Double(self.achievementInterstitial.progressPercentage) / 100.0)
        self.animatedBadge?.animateProgress(duration, endPercentage: self.achievementInterstitial.progressPercentage, completion: nil)
        
        // Assuming this achievement contains the most up-to-date fanloyalty info,
        // we update the user's level and level progress when the interstitial appears
        VObjectManager.sharedManager().mainUser?.level = achievementInterstitial.level
        VObjectManager.sharedManager().mainUser?.levelProgressPercentage = achievementInterstitial.progressPercentage
    }
    
    private func layoutContent() {
        
        view.addSubview(dismissalView)
        view.v_addFitToParentConstraintsToSubview(dismissalView)
        
        containerView.backgroundColor = UIColor.whiteColor()
        containerView.layer.cornerRadius = 6
        containerView.layer.masksToBounds = true
        
        view.addSubview(containerView)
        containerView.backgroundColor = UIColor.whiteColor()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addConstraint(NSLayoutConstraint(item: containerView, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: AnimationConstants.containerWidth))
        view.addConstraint(NSLayoutConstraint(item: containerView, attribute: .CenterX, relatedBy: .Equal, toItem: view, attribute: .CenterX, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: containerView, attribute: .CenterY, relatedBy: .Equal, toItem: view, attribute: .CenterY, multiplier: 1, constant: -10))
        
        containerView.addSubview(dismissButton)
        dismissButton.translatesAutoresizingMaskIntoConstraints = false
        dismissButton.addTarget(self, action: "pressedDismiss", forControlEvents: .TouchUpInside)
        containerView.v_addPinToLeadingTrailingToSubview(dismissButton)
        
        containerView.addSubview(iconImageView)
        iconImageView.contentMode = .ScaleAspectFit
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        containerView.v_addPinToLeadingTrailingToSubview(iconImageView)
        
        containerView.addSubview(descriptionLabel)
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.numberOfLines = 0
        descriptionLabel.backgroundColor = UIColor.clearColor()
        descriptionLabel.textAlignment = NSTextAlignment.Center
        descriptionLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
        containerView.v_addPinToLeadingTrailingToSubview(descriptionLabel, leading: 60, trailing: 60)
        
        containerView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.numberOfLines = 0
        titleLabel.backgroundColor = UIColor.clearColor()
        titleLabel.textAlignment = NSTextAlignment.Center
        titleLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
        containerView.v_addPinToLeadingTrailingToSubview(titleLabel, leading: 10, trailing: 10)
        
        var verticalConstraintString: String
        var views: [String : UIView]
        
        if let animatedBadge = animatedBadge {
            animatedBadge.translatesAutoresizingMaskIntoConstraints = false
            containerView.addSubview(animatedBadge)
            verticalConstraintString = "V:|-23-[badgeView(70)]-29-[title]-20-[description][icon][button(64)]|"
            views = ["badgeView" : animatedBadge, "button" : dismissButton, "icon" : iconImageView, "description" : descriptionLabel, "title" : titleLabel]
            
            animatedBadge.v_addWidthConstraint(60)
            containerView.v_addCenterHorizontallyConstraintsToSubview(animatedBadge)
        }
        else {
            verticalConstraintString = "V:|-23-[title]-20-[description][icon][button(40)]|"
            views = ["button" : dismissButton, "icon" : iconImageView, "description" : descriptionLabel, "title" : titleLabel]
        }
        
        // Add vertical constraints
        containerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(verticalConstraintString, options: [], metrics: nil, views: views))
        
        // Add a constraint that will hide and show the image view depending on if there's an icon
        iconImageView.addConstraint(iconImageViewHeightConstraint)
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    /// MARK: Actions
    
    func pressedDismiss() {
        self.interstitialDelegate?.dismissInterstitial(self)
    }
    
    func tappedBackground() -> Void {
        self.interstitialDelegate?.dismissInterstitial(self)
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
    
    func presentationController(presentedViewController: UIViewController, presentingViewController: UIViewController) -> UIPresentationController {
        return AchievementPresentationController(presentedViewController: presentedViewController, presentingViewController: presentingViewController)
    }
    
    func preferredModalPresentationStyle() -> UIModalPresentationStyle {
        return .Custom
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
