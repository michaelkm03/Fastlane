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

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var containerView: UIView!
    
    private var dependencyManager: VDependencyManager!
    private var topAnchorConstraint: NSLayoutConstraint!
    private var timerManager: VTimerManager?
    
    private struct Constants {
        static let slideInAnimationDuration = NSTimeInterval(0.4)
        static let slideOutAnimationDuration = NSTimeInterval(0.4)
        
        static let toastViewHeight: CGFloat = 40
        static let topOffset = CGFloat(0)
    }
    
    // MARK: - Initialization
    
    class func newWithDependencyManager(dependencyManager: VDependencyManager) -> InterstitialToastViewController {
        let toastViewController = InterstitialToastViewController.v_initialViewControllerFromStoryboard() as InterstitialToastViewController
        toastViewController.dependencyManager = dependencyManager
        return toastViewController
    }

    private func configure(withTitle title: String, detailedDescription detail: String? = nil) {
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
    
    func presentationController(presentedViewController: UIViewController, presentingViewController: UIViewController) -> UIPresentationController {
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
    
    override func viewDidAppear(animated: Bool) {
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

    override func willMoveToParentViewController(parent: UIViewController?) {
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
    
    @IBAction private func handlePan(sender: UIPanGestureRecognizer) {
        if sender.state == .Ended && sender.translationInView(view).y < 0 {
            dismiss()
        }
    }
    
    @objc private func dismiss() {
        timerManager?.invalidate()
        slideOut() {
            self.interstitialDelegate?.dismissInterstitial(self)
        }
    }
    
    // MARK: - Private Methods
    
    private func styleComponents() {
        titleLabel.font = dependencyManager.titleFont
        titleLabel.textColor = dependencyManager.textColor

        descriptionLabel.font = dependencyManager.detailLabelFont
        descriptionLabel.textColor = dependencyManager.textColor

        dependencyManager.addBackgroundToBackgroundHost(self)
    }
    
    private func slideIn() {
        view.layoutIfNeeded()
        UIView.animateWithDuration(Constants.slideInAnimationDuration) {
            self.topAnchorConstraint.constant = Constants.topOffset
            self.view.layoutIfNeeded()
        }
    }

    private func slideOut(completion: () -> Void) {
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
        return fontForKey("font.title")
    }
    
    var detailLabelFont: UIFont? {
        return fontForKey("font.detail")
    }
    
    var textColor: UIColor? {
        return colorForKey("color.text")
    }
}
