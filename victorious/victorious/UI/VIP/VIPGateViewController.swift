//
//  VIPGateViewController.swift
//  victorious
//
//  Created by Patrick Lynch on 3/4/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit
import MBProgressHUD

/// Conformers will receive a message when the vip gate
/// will dismiss or has permitted the user to pass through.
protocol VIPGateViewControllerDelegate: class {
    func vipGateViewController(vipGateViewController: VIPGateViewController, allowedAccess allowed: Bool)
    
    /// Presents a VIP flow on the scaffold using values found in the provided dependency manager.
    func showVIPForumFromDependencyManager(dependencyManager: VDependencyManager)
}

extension VIPGateViewControllerDelegate {
    func showVIPForumFromDependencyManager(dependencyManager: VDependencyManager) {
        guard let scaffold = VRootViewController.sharedRootViewController()?.scaffold else {
            return
        }
        let router = Router(originViewController: scaffold, dependencyManager: dependencyManager)
        let destination = DeeplinkDestination.vipForum
        router.navigate(to: destination)
    }
}

class VIPGateViewController: UIViewController {
    @IBOutlet weak private var textView: UITextView!
    @IBOutlet weak private var subscribeButton: UIButton!
    @IBOutlet weak private var restoreButton: UIButton!
    @IBOutlet weak private var privacyPolicyButton: UIButton!
    @IBOutlet weak private var termsOfServiceButton: UIButton!
    @IBOutlet weak private var legalPromptLabel: UILabel!
    
    weak var delegate: VIPGateViewControllerDelegate?
    
    private var productIdentifier: String!
    
    var dependencyManager: VDependencyManager! {
        didSet {
            updateViews()
        }
    }

    // MARK: - Initialization

    class func newWithDependencyManager(dependencyManager: VDependencyManager) -> VIPGateViewController? {
        guard
            let productIdentifier = dependencyManager.vipSubscription?.productIdentifier,
            let currentUser = VCurrentUser.user()
            where !currentUser.hasValidVIPSubscription
        else {
            return nil
        }
        
        let viewController: VIPGateViewController = VIPGateViewController.v_initialViewControllerFromStoryboard("VIPGate")
        viewController.dependencyManager = dependencyManager
        viewController.title = dependencyManager.stringForKey("title")
        viewController.productIdentifier = productIdentifier
        return viewController
    }

    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateViews()
    }
    
    // MARK: - IBActions
    
    @IBAction func onSubscribe(sender: UIButton? = nil) {
        let subscribe = VIPSubscribeOperation(productIdentifier: productIdentifier)
        
        setIsLoading(true, title: Strings.purchaseInProgress)
        subscribe.queue() { error, canceled in
            self.setIsLoading(false)
            guard !canceled else {
                return
            }
            
            if let error = error {
                let title = Strings.subscriptionFailed
                let message = error.localizedDescription
                self.v_showErrorWithTitle(title, message: message)
            } else {
                self.onSubcriptionValidated()
            }
        }
    }
    
    @IBAction func onRestore(sender: UIButton? = nil) {
        let restore = RestorePurchasesOperation()
        
        setIsLoading(true, title: Strings.restoreInProgress)
        restore.queue() { error, canceled in
            self.setIsLoading(false)
            guard !canceled else {
                return
            }
            
            if let error = error {
                let title = Strings.restoreFailed
                let message = error.localizedDescription
                self.v_showErrorWithTitle(title, message: message)
            } else {
                self.onSubcriptionValidated()
            }
        }
    }
    
    @IBAction func onPrivacyPolicySelected() {
        ShowWebContentOperation(originViewController: self, type: .PrivacyPolicy, dependencyManager: dependencyManager).queue()
    }
    
    @IBAction func onTermsOfServiceSelected() {
        ShowWebContentOperation(originViewController: self, type: .TermsOfService, dependencyManager: dependencyManager).queue()
    }
    
    // MARK: - Private
    
    private func setIsLoading(isLoading: Bool, title: String? = nil) {
        if isLoading {
            MBProgressHUD.hideAllHUDsForView(self.view, animated: false)
            let progressHUD = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
            progressHUD.mode = .Indeterminate
            progressHUD.labelText = title
        } else {
            MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
        }
    }
    
    private func onSubcriptionValidated() {
        showResultWithMessage(Strings.purchaseSucceeded) {
            self.openGate()
        }
    }
    
    private func showResultWithMessage(message: String, completion: (() -> ())? = nil) {
        MBProgressHUD.hideAllHUDsForView(self.view, animated: false)
        let progressHUD = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        progressHUD.mode = .Text
        progressHUD.labelText = message
        
        dispatch_after(1.0) {
            MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
            completion?()
        }
    }
    
    private func openGate() {
        delegate?.vipGateViewController(self, allowedAccess: true)
    }
    
    private func updateViews() {
        guard isViewLoaded() else {
            return
        }
        
        legalPromptLabel.text = Strings.legalPrompt
        
        let privacyPolicyText = NSAttributedString(
            string: Strings.privacyPolicy,
            attributes: dependencyManager.legalLinkAttributes
        )
        privacyPolicyButton.setAttributedTitle(privacyPolicyText, forState: .Normal)
        
        let termsOfServiceText = NSAttributedString(
            string: Strings.termsOfService,
            attributes: dependencyManager.legalLinkAttributes
        )
        termsOfServiceButton.setAttributedTitle(termsOfServiceText, forState: .Normal)
        
        restoreButton.setTitle(Strings.restorePrompt, forState: .Normal)
        restoreButton.setTitleColor(dependencyManager.subscribeColor, forState: .Normal)
        
        subscribeButton.setTitle(dependencyManager.subscribeText, forState: .Normal)
        subscribeButton.backgroundColor = dependencyManager.subscribeColor
        
        textView.text = dependencyManager.greetingText
        textView.font = dependencyManager.greetingFont
        textView.textColor = dependencyManager.greetingColor
    }
    
    // MARK: - String Constants
    
    private struct Strings {
        static let legalPrompt              = NSLocalizedString("SubscriptionLegalPrompt", comment: "")
        static let privacyPolicy            = NSLocalizedString("Privacy Policy", comment: "")
        static let termsOfService           = NSLocalizedString("Terms of Service", comment: "")
        static let purchaseInProgress       = NSLocalizedString("ActivityPurchasing", comment: "")
        static let purchaseSucceeded        = NSLocalizedString("SubscriptionSucceeded", comment: "")
        static let restoreFailed            = NSLocalizedString("SubscriptionRestoreFailed", comment: "")
        static let restoreInProgress        = NSLocalizedString("SubscriptionActivityRestoring", comment: "")
        static let restorePrompt            = NSLocalizedString("SubscriptionRestorePrompt", comment: "")
        static let restoreSucceeded         = NSLocalizedString("SubscriptionRestoreSucceeded", comment: "")
        static let subscriptionFailed       = NSLocalizedString("SubscriptionFailed", comment: "")
    }
}

private extension VDependencyManager {
    var greetingText: String {
        return stringForKey("greeting.text") ?? ""
    }
    
    var greetingFont: UIFont {
        return fontForKey("greeting.font") ?? UIFont.systemFontOfSize(13.0)
    }
    
    var greetingColor: UIColor {
        return colorForKey("greeting.color") ?? UIColor.blackColor()
    }
    
    var subscribeColor: UIColor {
        return colorForKey("subscribe.color") ?? UIColor.blackColor()
    }
    
    var subscribeText: String {
        return stringForKey("subscribe.text") ?? ""
    }
    
    var backgroundColor: UIColor? {
        let background = templateValueOfType(VSolidColorBackground.self, forKey: "background") as? VSolidColorBackground
        return background?.backgroundColor
    }
    
    var legalLinkAttributes: [String : AnyObject] {
        return [
            NSFontAttributeName: fontForKey("font.paragraph"),
            NSForegroundColorAttributeName: subscribeColor,
            NSUnderlineStyleAttributeName: NSNumber(integer: NSUnderlineStyle.StyleSingle.rawValue)
        ]
    }
}
