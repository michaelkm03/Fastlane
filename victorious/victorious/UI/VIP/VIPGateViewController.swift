//
//  VIPGateViewController.swift
//  victorious
//
//  Created by Patrick Lynch on 3/4/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit
import MBProgressHUD

class VIPGateViewController: UIViewController, VNavigationDestination {
    
    @IBOutlet weak private var textView: UITextView!
    @IBOutlet weak private var subscribeButton: UIButton!
    @IBOutlet weak private var restoreButton: UIButton!
    @IBOutlet weak private var privacyPolicyButton: UIButton!
    @IBOutlet weak private var termsOfServiceButton: UIButton!
    @IBOutlet weak private var legalPromptLabel: UILabel!
    
    private lazy var vipIconView: UIView = {
        let imageView = UIImageView(image: UIImage(named:"vip")!.imageWithRenderingMode(.AlwaysTemplate))
        imageView.tintColor = UIColor.whiteColor()
        return imageView
    }()
    
    var dependencyManager: VDependencyManager! {
        didSet {
            updateViews()
        }
    }

    //MARK: - Initialization

    class func newWithDependencyManager(dependencyManager: VDependencyManager) -> VIPGateViewController {
        let viewController: VIPGateViewController = VIPGateViewController.v_initialViewControllerFromStoryboard("VIPGate")
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
    
    func shouldNavigateWithAlternateDestination(alternateViewController: AutoreleasingUnsafeMutablePointer<AnyObject?>) -> Bool {
        // Don't allow this tab to be selected if already validated as a VIP subscriber,
        // skip ahead to presenting the VIP Forum section
        if let currentUser = VCurrentUser.user() where currentUser.isVIPSubscriber.boolValue {
            openGate()
            return false
        }
        return true
    }
    
    // MARK: - IBActions
    
    @IBAction func onSubscribe(sender: UIButton? = nil) {
        let productIdentifier = dependencyManager.vipSubscriptionProductIdentifier!
        let subscribe = VIPSubscribeOperation(productIdentifier: productIdentifier)
        
        setIsLoading(true, title: Strings.purchaseInProgress)
        subscribe.queue() { error, canceled in
            self.setIsLoading(false)
            guard !canceled else {
                return
            }
            
            if let error = error {
                let title = Strings.suscribeFailed
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
        ShowPrivacyPolicyOperation(dependencyManager: dependencyManager).queue()
    }
    
    @IBAction func onTermsOfServiceSelected() {
        ShowTermsOfServiceOperation(dependencyManager: dependencyManager).queue()
    }
    
    // MARK: - Private
    
    private func setIsLoading(isLoading: Bool, title: String? = nil) {
        if isLoading {
            MBProgressHUD.hideAllHUDsForView(self.view, animated: false)
            let progressHUD = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
            progressHUD.mode = .CustomView
            progressHUD.customView = vipIconView
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
    
    private func showResultWithMessage(message: String, completion:(()->())? = nil) {
        MBProgressHUD.hideAllHUDsForView(self.view, animated: false)
        let progressHUD = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        progressHUD.mode = .CustomView
        progressHUD.customView = vipIconView
        progressHUD.labelText = message
        
        dispatch_after(1.0) {
            MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
            completion?()
        }
    }
    
    private func openGate() {
        let originVC = dependencyManager.scaffoldViewController()
        ShowForumOperation(originViewController: originVC, dependencyManager: dependencyManager).queue() { _ in
            self.dependencyManager.scaffoldViewController()?.setSelectedMenuItemAtIndex(0)
        }
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
        static let legalPrompt              = NSLocalizedString("By subscring you are agreeing to our", comment:"")
        static let privacyPolicy            = NSLocalizedString("privacy policy", comment:"")
        static let termsOfService           = NSLocalizedString("terms of service", comment:"")
        static let purchaseInProgress       = NSLocalizedString("ActivityPurchasing", comment:"")
        static let purchaseSucceeded        = NSLocalizedString("Subscription complete!", comment:"")
        static let restoreFailed            = NSLocalizedString("Failed to restore subcription.", comment:"")
        static let restoreInProgress        = NSLocalizedString("Checking for subscription...", comment:"")
        static let restorePrompt            = NSLocalizedString("Already subscribed?", comment:"")
        static let restoreSucceeded         = NSLocalizedString("Subscription restored!", comment:"")
        static let suscribeFailed           = NSLocalizedString("Subscription failed.", comment:"")
        static let validationFailedTitle    = NSLocalizedString("Validation Failed", comment: "")
    }
}

private extension VDependencyManager {
    
    var greetingText: String {
        return stringForKey("greeting.text")
    }
    
    var greetingFont: UIFont {
        return fontForKey("greeting.font")
    }
    
    var greetingColor: UIColor {
        return colorForKey("greeting.color")
    }
    
    var subscribeColor: UIColor {
        return colorForKey("subscribe.color")
    }
    
    var subscribeText: String {
        return stringForKey("subscribe.text")
    }
    
    var backgroundColor: UIColor? {
        let background = templateValueOfType( VSolidColorBackground.self, forKey: "background") as? VSolidColorBackground
        return background?.backgroundColor
    }
    
    var legalLinkAttributes: [String : AnyObject] {
        return [
            NSFontAttributeName : fontForKey("font.paragraph"),
            NSForegroundColorAttributeName : colorForKey("subscribe.color"),
            NSUnderlineStyleAttributeName: NSNumber(integer: NSUnderlineStyle.StyleSingle.rawValue)
        ]
    }
}
