//
//  InterstitialToastViewController.swift
//  victorious
//
//  Created by Tian Lan on 4/5/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

/// A component that displays an alert as a toast.
/// It slides in from the top of the screen, similar to a system push notification, and the gets dismissed automatically after a period of time. 
/// Or it can also be dismissed if the user swipe up on the toast.
class InterstitialToastViewController: UIViewController, Interstitial, VBackgroundContainer {

    @IBOutlet fileprivate weak var titleLabel: UILabel!
    @IBOutlet fileprivate weak var descriptionLabel: UILabel!
    @IBOutlet fileprivate weak var containerView: UIView!
    
    fileprivate var dependencyManager: VDependencyManager!
    fileprivate var topAnchorConstraint: NSLayoutConstraint!
    fileprivate var timerManager: VTimerManager?
    
    fileprivate struct Constants {
        static let slideInAnimationDuration = TimeInterval(0.4)
        static let slideOutAnimationDuration = TimeInterval(0.4)
        
        static let toastViewHeight: CGFloat = 40
        static let topOffset = CGFloat(0)
    }
    
    // MARK: - Initialization
    
    class func new(with dependencyManager: VDependencyManager) -> InterstitialToastViewController {
        let toastViewController = InterstitialToastViewController.v_initialViewControllerFromStoryboard() as InterstitialToastViewController
        toastViewController.dependencyManager = dependencyManager
        return toastViewController
    }

    fileprivate func configure(withTitle title: String, detailedDescription detail: String? = nil) {
        titleLabel.text = title

        // FUTURE: toasts don't support details any more, maybe they will in the future so don't want to rip this out
        descriptionLabel.text = detail
        descriptionLabel.hidden = (detail == nil)
    }
    
    // MARK: - Interstitial Protocol
    
    var alert: Alert?

    weak var interstitialDelegate: InterstitialDelegate?
    
    func presentationAnimator() -> UIViewControllerAnimatedTransitioning? {
        return nil
    }
    
    func dismissalAnimator() -> UIViewControllerAnimatedTransitioning? {
        return nil
    }
    
    func presentationController(_ presentedViewController: UIViewController, presentingViewController: UIViewController?) -> UIPresentationController {
        return UIPresentationController(presentedViewController: presentedViewController, presentingViewController: presentingViewController)
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
            configure(withTitle: alert.parameters.title, detailedDescription: alert.parameters.description)
        }
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return .Portrait
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        guard let dismissalTime = alert?.parameters.dismissalTime else {
            return
        }

        timerManager = VTimerManager.scheduledTimerManagerWithTimeInterval(dismissalTime,
            target: self,
            selector: #selector(dismiss),
            userInfo: nil,
            repeats: false
        )
    }

    override func willMoveToParentViewController(_ parent: UIViewController?) {
        guard let parent = parent else {
            return
        }
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.heightAnchor.constraintEqualToConstant(Constants.toastViewHeight).active = true
        view.leftAnchor.constraintEqualToAnchor(parent.view.leftAnchor).active = true
        view.rightAnchor.constraintEqualToAnchor(parent.view.rightAnchor).active = true
        topAnchorConstraint = view.topAnchor.constraintEqualToAnchor(parent.view.topAnchor, constant: -Constants.toastViewHeight)
        topAnchorConstraint.active = true

        slideIn()
    }
    
    // MARK: - User Actions
    
    @IBAction fileprivate func handlePan(_ sender: UIPanGestureRecognizer) {
        if sender.state == .Ended && sender.translationInView(view).y < 0 {
            dismiss()
        }
    }
    
    @objc fileprivate func dismiss() {
        timerManager?.invalidate()
        slideOut() {
            self.interstitialDelegate?.dismissInterstitial(self)
        }
    }
    
    // MARK: - Private Methods
    
    fileprivate func styleComponents() {
        titleLabel.font = dependencyManager.titleFont
        titleLabel.textColor = dependencyManager.textColor

        descriptionLabel.font = dependencyManager.detailLabelFont
        descriptionLabel.textColor = dependencyManager.textColor

        dependencyManager.addBackgroundToBackgroundHost(self)
    }
    
    fileprivate func slideIn() {
        view.layoutIfNeeded()
        UIView.animateWithDuration(Constants.slideInAnimationDuration) {
            self.topAnchorConstraint.constant = Constants.topOffset
            self.view.layoutIfNeeded()
        }
    }

    fileprivate func slideOut(_ completion: @escaping () -> Void) {
        view.layoutIfNeeded()
        UIView.animateWithDuration(Constants.slideOutAnimationDuration,
            animations: {
                self.topAnchorConstraint.constant = -Constants.toastViewHeight
                self.view.layoutIfNeeded()
            },
            completion: { completed in
                completion()
            })
    }
}

private extension VDependencyManager {
    
    var titleFont: UIFont? {
        return font(forKey: "font.title")
    }
    
    var detailLabelFont: UIFont? {
        return font(forKey: "font.detail")
    }
    
    var textColor: UIColor? {
        return color(forKey: "color.text")
    }
}
