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
    
    @IBOutlet fileprivate weak var iconImageView: UIImageView?
    @IBOutlet fileprivate weak var titleLabel: UILabel!
    @IBOutlet fileprivate weak var detailLabel: UILabel!
    @IBOutlet fileprivate weak var confirmButton: UIButton!
    @IBOutlet fileprivate weak var semiTransparentBackgroundButton: UIButton!
    @IBOutlet fileprivate weak var containerView: UIView!
    
    fileprivate var dependencyManager: VDependencyManager!
    
    fileprivate struct Constants {
        static let cornerRadius: CGFloat = 10
    }
    
    // MARK: - Initialization
    
    class func new(withDependencyManager dependencyManager: VDependencyManager) -> InterstitialAlertViewController {
        let imageAlertViewController = InterstitialAlertViewController.v_initialViewControllerFromStoryboard() as InterstitialAlertViewController
        imageAlertViewController.dependencyManager = dependencyManager
        
        return imageAlertViewController
    }
    
    fileprivate func configure(withTitle title: String, detailedDescription detail: String?, iconImageURL iconURL: URL?) {
        titleLabel.text = title
        
        if let detail = detail {
            detailLabel.isHidden = false
            detailLabel.text = detail
        } else {
            detailLabel.isHidden = true
            detailLabel.text = nil
        }
        
        if let iconURL = iconURL {
            iconImageView?.isHidden = false
            iconImageView?.sd_setImage(with: iconURL)
        } else {
            iconImageView?.isHidden = true
        }
    }
    
    // MARK: - Interstitial Protocol
    
    func presentationAnimator() -> UIViewControllerAnimatedTransitioning? {
        return InterstitialAlertAnimator(isDismissing: false)
    }
    
    func dismissalAnimator() -> UIViewControllerAnimatedTransitioning? {
        return InterstitialAlertAnimator(isDismissing: true)
    }
    
    func presentationController(_ presentedViewController: UIViewController, presentingViewController: UIViewController?) -> UIPresentationController {
        return InterstitialAlertPresentationController(presentedViewController: presentedViewController, presenting: presentingViewController)
    }
    
    func preferredModalPresentationStyle() -> UIModalPresentationStyle {
        return .custom
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
            configure(withTitle: alert.parameters.title, detailedDescription: alert.parameters.description, iconImageURL: alert.parameters.icons?.first as URL?)
        }
    }
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return .portrait
    }
    
    @IBAction func dismiss(_ sender: UIButton) {
        interstitialDelegate?.dismissInterstitial(self)
    }
    
    // MARK: - Private Methods
    
    fileprivate func styleComponents() {
        containerView.layer.cornerRadius = Constants.cornerRadius
        
        titleLabel.font = dependencyManager.titleFont
        titleLabel.textColor = dependencyManager.textColor
        
        detailLabel.font = dependencyManager.detailLabelFont
        detailLabel.textColor = dependencyManager.textColor
        
        confirmButton.layer.cornerRadius = Constants.cornerRadius
        confirmButton.titleLabel?.font = dependencyManager.confirmButtonTitleFont
        confirmButton.setTitleColor(dependencyManager.confirmButtonTitleColor, for: .normal)
        confirmButton.setTitleColor(dependencyManager.confirmButtonTitleColor?.withAlphaComponent(0.5), for: .highlighted)
        confirmButton.backgroundColor = dependencyManager.confirmButtonBackgroundColor
        confirmButton.setTitle(dependencyManager.confirmButtonTitle, for: .normal)
        
        dependencyManager.addBackground(toBackgroundHost: self)
    }
}

private extension VDependencyManager {
    var confirmButtonBackgroundColor: UIColor? {
        return color(forKey: VDependencyManagerLinkColorKey)
    }
    
    var confirmButtonTitleFont: UIFont? {
        return font(forKey: VDependencyManagerHeading4FontKey)
    }
    
    var confirmButtonTitleColor: UIColor? {
        return color(forKey: VDependencyManagerContentTextColorKey)
    }
    
    var titleFont: UIFont? {
        return font(forKey: VDependencyManagerHeading3FontKey)
    }
    
    var detailLabelFont: UIFont? {
        return font(forKey: VDependencyManagerParagraphFontKey)
    }
    
    var textColor: UIColor? {
        return color(forKey: VDependencyManagerMainTextColorKey)
    }
    
    var confirmButtonTitle: String? {
        return string(forKey: "button.title")
    }
}
