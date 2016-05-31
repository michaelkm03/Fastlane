//
//  VIPGateViewController.swift
//  victorious
//
//  Created by Patrick Lynch on 3/4/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit
import MBProgressHUD

protocol VIPGateViewControllerDelegate: class {
    
    func vipGateExitedWithSuccess(success: Bool, afterPurchase purchased: Bool)
}

@objc(VVIPGateViewController)
class VIPGateViewController: UIViewController {
    
    @IBOutlet weak private var headlineLabel: UILabel!
    @IBOutlet weak private var detailLabel: UILabel!
    @IBOutlet weak private var subscribeButton: UIButton! //FUTURE: Make this a `textOnImage.button` once available
    @IBOutlet weak private var restoreButton: UIButton!
    @IBOutlet weak private var privacyPolicyButton: UIButton!
    @IBOutlet weak private var termsOfServiceButton: UIButton!
    @IBOutlet weak private var closeButton: UIButton!
    
    weak var delegate: VIPGateViewControllerDelegate?
    
    var dependencyManager: VDependencyManager! {
        didSet {
            updateViews()
        }
    }

    //MARK: - Initialization

    class func newWithDependencyManager(dependencyManager: VDependencyManager) -> VIPGateViewController {
        let viewController: VIPGateViewController = v_initialViewControllerFromStoryboard()
        viewController.dependencyManager = dependencyManager
        viewController.title = dependencyManager.stringForKey("title")
        return viewController
    }

    //MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateViews()
    }
    
    // MARK: - VNavigationDestination
    
    func shouldNavigate() -> Bool {
        // Don't allow this tab to be selected if already validated as a VIP subscriber,
        // skip ahead to presenting the VIP Forum section
        if let currentUser = VCurrentUser.user() where currentUser.isVIPSubscriber.boolValue {
            openGate(afterPurchase: false)
            return false
        }
        return true
    }
    
    // MARK: - IBActions
    
    @IBAction func onSubscribe(sender: UIButton? = nil) {
        let productIdentifier = dependencyManager.vipSubscription?.productIdentifier ?? ""
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
        ShowPrivacyPolicyOperation(originViewController: self).queue()
    }
    
    @IBAction func onTermsOfServiceSelected() {
        ShowTermsOfServiceOperation(originViewController: self).queue()
    }
    
    @IBAction func onCloseSelected() {
        delegate?.vipGateExitedWithSuccess(false, afterPurchase: false)
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
            self.openGate(afterPurchase: true)
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
    
    private func openGate(afterPurchase purchased: Bool) {
        delegate?.vipGateExitedWithSuccess(true, afterPurchase: purchased)
    }
    
    private func updateViews() {
        guard isViewLoaded() else {
            return
        }
        
        let privacyPolicyText = NSMutableAttributedString(
            string: dependencyManager.privacyPolicyText ?? Strings.privacyPolicy
        )
        if let attributes = dependencyManager.privacyPolicyLinkAttributes {
            privacyPolicyText.addAttributes(attributes, range: NSMakeRange(0, privacyPolicyText.length))
        }
        privacyPolicyButton.setAttributedTitle(privacyPolicyText, forState: .Normal)
        
        let termsOfServiceText = NSMutableAttributedString(
            string: dependencyManager.termsOfService ?? Strings.termsOfService
        )
        if let attributes = dependencyManager.termsOfServiceLinkAttributes {
            termsOfServiceText.addAttributes(attributes, range: NSMakeRange(0, termsOfServiceText.length))
        }
        termsOfServiceButton.setAttributedTitle(termsOfServiceText, forState: .Normal)
        
        restoreButton.setTitle(dependencyManager.restoreText ?? Strings.restorePrompt, forState: .Normal)
        restoreButton.setTitleColor(dependencyManager.restoreTextColor, forState: .Normal)
        if let font = dependencyManager.restoreFont {
            restoreButton.titleLabel?.font = font
        }
        
        headlineLabel.text = dependencyManager.headerText
        if let color = dependencyManager.headerTextColor {
            headlineLabel.textColor = color
        }
        if let font = dependencyManager.headerFont {
            headlineLabel.font = font
        }
        
        detailLabel.text = dependencyManager.descriptionText
        if let color = dependencyManager.descriptionTextColor {
            detailLabel.textColor = color
        }
        if let font = dependencyManager.descriptionFont {
            detailLabel.font = font
        }
        
        closeButton.setBackgroundImage(dependencyManager.closeIcon, forState: .Normal)
        if let color = dependencyManager.closeIconTintColor {
            closeButton.tintColor = color
        }
        
//        subscribeButton.dependencyManager = dependencyManager
    }
    
    // MARK: - String Constants
    
    private struct Strings {
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
    
    var headerText: String? {
        return stringForKey("text.header")
    }
    
    var headerFont: UIFont? {
        return fontForKey("font.header")
    }
    
    var headerTextColor: UIColor? {
        return colorForKey("color.header")
    }
    
    var descriptionText: String? {
        return stringForKey("text.description")
    }
    
    var descriptionFont: UIFont? {
        return fontForKey("font.description")
    }
    
    var descriptionTextColor: UIColor? {
        return colorForKey("color.description")
    }
    
    var restoreText: String? {
        return stringForKey("text.restore")
    }
    
    var restoreFont: UIFont? {
        return fontForKey("font.restore")
    }
    
    var restoreTextColor: UIColor? {
        return colorForKey("color.restore")
    }
    
    var termsOfServiceLinkAttributes: [String : AnyObject]? {
        
        guard let font = fontForKey("font.tos"),
            let color = colorForKey("color.tos") else {
                return nil
        }
        
        return [
            NSFontAttributeName: font,
            NSForegroundColorAttributeName: color,
            NSUnderlineStyleAttributeName: NSNumber(integer: NSUnderlineStyle.StyleSingle.rawValue)
        ]
    }
    
    var termsOfService: String? {
        return stringForKey("text.tos")
    }
    
    var privacyPolicyLinkAttributes: [String : AnyObject]? {
        
        guard let font = fontForKey("font.privacy"),
            let color = colorForKey("color.privacy") else {
                return nil
        }
        
        return [
            NSFontAttributeName: font,
            NSForegroundColorAttributeName: color,
            NSUnderlineStyleAttributeName: NSNumber(integer: NSUnderlineStyle.StyleSingle.rawValue)
        ]
    }
    
    var privacyPolicyText: String? {
        return stringForKey("text.privacy")
    }
    
    var closeIcon: UIImage? {
        return imageForKey("closeIcon")
    }
    
    var closeIconTintColor: UIColor? {
        return colorForKey("color.closeIcon")
    }
}
