//
//  InterstitialAlertViewController.swift
//  victorious
//
//  Created by Tian Lan on 3/28/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

class InterstitialAlertViewController: UIViewController, Interstitial, VBackgroundContainer {

    var alert: Alert?
    weak var interstitialDelegate: InterstitialDelegate?
    
    @IBOutlet private weak var iconImageView: UIImageView?
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var detailLabel: UILabel!
    @IBOutlet private weak var confirmButton: UIButton!
    @IBOutlet private weak var semiTransparentBackgroundButton: UIButton!
    @IBOutlet private weak var containerView: UIView!
    
    private var dependencyManager: VDependencyManager!
    
    private struct Constants {
        static let cornerRadius: CGFloat = 10
    }
    
    // MARK: - Initialization
    
    class func newWithDependencyManager(dependencyManager: VDependencyManager) -> InterstitialAlertViewController {
        let imageAlertViewController = InterstitialAlertViewController.v_initialViewControllerFromStoryboard() as InterstitialAlertViewController
        imageAlertViewController.dependencyManager = dependencyManager
        
        return imageAlertViewController
    }
    
    private func configure(withTitle title: String, detailedDescription detail: String?, iconImageURL iconURL: NSURL?) {
        titleLabel.text = title
        
        if let detail = detail {
            detailLabel.hidden = false
            detailLabel.text = detail
        } else {
            detailLabel.hidden = true
            detailLabel.text = nil
        }
        
        if let iconURL = iconURL {
            iconImageView?.hidden = false
            iconImageView?.sd_setImageWithURL(iconURL)
        } else {
            iconImageView?.hidden = true
        }
    }
    
    // MARK: - Interstitial Protocol
    
    func presentationAnimator() -> UIViewControllerAnimatedTransitioning? {
        return InterstitialAlertAnimator(isDismissing: false)
    }
    
    func dismissalAnimator() -> UIViewControllerAnimatedTransitioning? {
        return InterstitialAlertAnimator(isDismissing: true)
    }
    
    func presentationController(presentedViewController: UIViewController, presentingViewController: UIViewController?) -> UIPresentationController {
        return InterstitialAlertPresentationController(presentedViewController: presentedViewController, presentingViewController: presentingViewController)
    }
    
    func preferredModalPresentationStyle() -> UIModalPresentationStyle {
        return .Custom
    }
    
    // MARK: - VBackgroundContainer Protocol
    
    func backgroundContainerView() -> UIView {
        return containerView
    }
    
    // MARK: - View Controller Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        styleComponents()
        if let alert = alert {
            configure(withTitle: alert.parameters.title, detailedDescription: alert.parameters.description, iconImageURL: alert.parameters.icons?.first)
        }
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return .Portrait
    }
    
    @IBAction func dismiss(sender: UIButton) {
        interstitialDelegate?.dismissInterstitial(self)
    }
    
    // MARK: - Private Methods
    
    private func styleComponents() {
        containerView.layer.cornerRadius = Constants.cornerRadius
        
        titleLabel.font = dependencyManager.titleFont
        titleLabel.textColor = dependencyManager.textColor
        
        detailLabel.font = dependencyManager.detailLabelFont
        detailLabel.textColor = dependencyManager.textColor
        
        confirmButton.layer.cornerRadius = Constants.cornerRadius
        confirmButton.titleLabel?.font = dependencyManager.confirmButtonTitleFont
        confirmButton.setTitleColor(dependencyManager.confirmButtonTitleColor, forState: .Normal)
        confirmButton.setTitleColor(dependencyManager.confirmButtonTitleColor?.colorWithAlphaComponent(0.5), forState: .Highlighted)
        confirmButton.backgroundColor = dependencyManager.confirmButtonBackgroundColor
        confirmButton.setTitle(dependencyManager.confirmButtonTitle, forState: .Normal)
        
        dependencyManager.addBackgroundToBackgroundHost(self)
    }
}

private extension VDependencyManager {
    var confirmButtonBackgroundColor: UIColor? {
        return colorForKey(VDependencyManagerLinkColorKey)
    }
    
    var confirmButtonTitleFont: UIFont? {
        return fontForKey(VDependencyManagerHeading4FontKey)
    }
    
    var confirmButtonTitleColor: UIColor? {
        return colorForKey(VDependencyManagerContentTextColorKey)
    }
    
    var titleFont: UIFont? {
        return fontForKey(VDependencyManagerHeading3FontKey)
    }
    
    var detailLabelFont: UIFont? {
        return fontForKey(VDependencyManagerParagraphFontKey)
    }
    
    var textColor: UIColor? {
        return colorForKey(VDependencyManagerMainTextColorKey)
    }
    
    var confirmButtonTitle: String? {
        return stringForKey("button.title")
    }
}
