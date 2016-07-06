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
    
    @IBOutlet private weak var iconImageView: UIImageView?
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var containerView: UIView!
    
    private var dependencyManager: VDependencyManager!
    private var topAnchorConstraint: NSLayoutConstraint!
    private var timerManager: VTimerManager?
    
    private struct Constants {
        static let automaticDismissalTime: NSTimeInterval = 3
        static let slideInAnimationTime: NSTimeInterval = 0.4
        static let slideOutAnimationTime: NSTimeInterval = 0.4
        
        static let toastViewHeight: CGFloat = 80
        static let statusBarHeight = UIApplication.sharedApplication().statusBarFrame.height
    }
    
    // MARK: - Initialization
    
    class func newWithDependencyManager(dependencyManager: VDependencyManager) -> InterstitialToastViewController {
        let toast = InterstitialToastViewController.v_initialViewControllerFromStoryboard() as InterstitialToastViewController
        toast.dependencyManager = dependencyManager
        
        return toast
    }
    
    private func configure(withTitle title: String, detailedDescription detail: String?, iconImageURL iconURL: NSURL? = nil) {
        titleLabel.text = title
        
        /// These two views are being hidden for now. Once spec for description and icon image is ready, we'll re-enable them.
        descriptionLabel.hidden = true
        iconImageView?.hidden = true
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
            configure(withTitle: alert.parameters.title, detailedDescription: alert.parameters.description, iconImageURL: alert.parameters.icons?.first)
        }
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return .Portrait
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        timerManager = VTimerManager.scheduledTimerManagerWithTimeInterval(Constants.automaticDismissalTime,
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
        switch sender.state {
        case .Ended:
            if sender.translationInView(view).y < 0 {
                dismiss()
            }
        default:
            break
        }
    }
    
    @IBAction private func handleTap(sender: UITapGestureRecognizer) {
        dismiss()
        
        let destination = DeeplinkDestination.trophyCase
        let router = Router(originViewController: self, dependencyManager: dependencyManager)
        router.navigate(to: destination)
    }
    
    func dismiss() {
        timerManager?.invalidate()
        slideOut() {
            self.interstitialDelegate?.dismissInterstitial(self)
        }
    }
    
    // MARK: - Private Methods
    
    private func styleComponents() {
        view.layer.addBottomShadow()
        
        titleLabel.font = dependencyManager.titleFont
        titleLabel.textColor = dependencyManager.textColor
        
        descriptionLabel.font = dependencyManager.detailLabelFont
        descriptionLabel.textColor = dependencyManager.textColor
        
        dependencyManager.addBackgroundToBackgroundHost(self)
    }
    
    private func slideIn() {
        view.layoutIfNeeded()
        
        UIView.animateWithDuration(Constants.slideInAnimationTime) {
            self.topAnchorConstraint.constant = Constants.statusBarHeight
            self.view.layoutIfNeeded()
        }
    }
    
    private func slideOut(completion: () -> Void) {
        view.layoutIfNeeded()
        
        UIView.animateWithDuration(Constants.slideOutAnimationTime,
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
        return fontForKey(VDependencyManagerHeading3FontKey)
    }
    
    var detailLabelFont: UIFont? {
        return fontForKey(VDependencyManagerParagraphFontKey)
    }
    
    var textColor: UIColor? {
        return colorForKey(VDependencyManagerMainTextColorKey)
    }
}

private extension CALayer {
    func addBottomShadow() {
        shadowColor = UIColor.blackColor().CGColor
        shadowOffset = CGSizeMake(0, 2)
        shadowRadius = 2
        shadowOpacity = 0.8
    }
}
