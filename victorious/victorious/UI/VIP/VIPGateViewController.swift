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
    func vipGateExitedWithSuccess(success: Bool)
    
    /// Presents a VIP flow on the scaffold using values found in the provided dependency manager.
    func showVIPForumFromDependencyManager(dependencyManager: VDependencyManager)
}

extension VIPGateViewControllerDelegate {
    func showVIPForumFromDependencyManager(dependencyManager: VDependencyManager) {
        guard let scaffold = VRootViewController.sharedRootViewController()?.scaffold else {
            return
        }
        let router = Router(originViewController: scaffold, dependencyManager: dependencyManager)
        router.navigate(to: .vipForum, from: nil)
    }
}

class VIPGateViewController: UIViewController, VIPSubscriptionHelperDelegate {
    @IBOutlet weak private var headlineLabel: UILabel!
    @IBOutlet weak private var detailLabel: UILabel!
    @IBOutlet weak private var subscribeButton: TextOnColorButton!
    @IBOutlet weak private var restoreButton: TextOnColorButton!
    @IBOutlet weak private var privacyPolicyButton: UIButton!
    @IBOutlet weak private var termsOfServiceButton: UIButton!
    @IBOutlet weak private var closeButton: ImageOnColorButton! {
        didSet {
            closeButton.dependencyManager = dependencyManager.closeButtonDependency
            closeButton.touchInsets = UIEdgeInsetsMake(-12, -12, -12, -12)
        }
    }
    
    @IBOutlet private var labelWidthConstraint: NSLayoutConstraint!
    @IBOutlet private var scrollViewInsetConstraints: [NSLayoutConstraint]!
    
    private lazy var vipSubscriptionHelper: VIPSubscriptionHelper? = {
        guard let subscriptionFetchURL = self.dependencyManager.subscriptionFetchURL else {
            return nil
        }
        return VIPSubscriptionHelper(subscriptionFetchURL: subscriptionFetchURL, delegate: self, originViewController: self, dependencyManager: self.dependencyManager)
    }()
    
    weak var delegate: VIPGateViewControllerDelegate?
        
    var dependencyManager: VDependencyManager! {
        didSet {
            updateViews()
        }
    }

    // MARK: - Initialization

    class func newWithDependencyManager(dependencyManager: VDependencyManager) -> VIPGateViewController {
        let viewController: VIPGateViewController = VIPGateViewController.v_initialViewControllerFromStoryboard()
        viewController.dependencyManager = dependencyManager
        viewController.title = dependencyManager.stringForKey("title")
        return viewController
    }

    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()
        updateViews()
        
        vipSubscriptionHelper?.fetchProducts { [weak self] products in
            guard let products = products else {
                return
            }
            
            self?.detailLabel.text = self?.dependencyManager.descriptionText(for: products)
        }
    }
    
    // MARK: - IBActions
    
    @IBAction func onSubscribe(sender: UIButton? = nil) {
        subscribeButton.dependencyManager?.trackButtonEvent(.tap)
        vipSubscriptionHelper?.subscribe()
    }
    
    @IBAction func onRestore(sender: UIButton? = nil) {
        restoreButton.dependencyManager?.trackButtonEvent(.tap)
        let restore = RestorePurchasesOperation(validationURL: dependencyManager.validationURL)
        setIsLoading(true, title: Strings.restoreInProgress)
        restore.queue() { [weak self] result in
            self?.setIsLoading(false)
            
            switch result {
                case .success:
                    self?.openGate()
                case .failure(let error):
                    let title = Strings.restoreFailed
                    let message = (error as NSError).localizedDescription
                    self?.v_showErrorWithTitle(title, message: message)
                case .cancelled:
                    break
            }
        }
    }
    
    @IBAction func onPrivacyPolicySelected() {
        navigateToFixedWebContent(.PrivacyPolicy)
    }
    
    @IBAction func onTermsOfServiceSelected() {
        navigateToFixedWebContent(.TermsOfService)
    }
    
    @IBAction func onCloseSelected() {
        closeButton.dependencyManager?.trackButtonEvent(.tap)
        delegate?.vipGateExitedWithSuccess(false)
    }
    
    // MARK: - Private
    
    private func navigateToFixedWebContent(type: FixedWebContentType) {
        let router = Router(originViewController: self, dependencyManager: dependencyManager)
        let configuration = ExternalLinkDisplayConfiguration(addressBarVisible: false, forceModal: true, isVIPOnly: false, title: type.title)
        router.navigate(to: .externalURL(url: dependencyManager.urlForFixedWebContent(type), configuration: configuration), from: nil)
    }
    
    private func HUDNeedsUpdateToTitle(title: String?) -> Bool {
        if let huds = MBProgressHUD.allHUDsForView(self.view) as? [MBProgressHUD] {
            if
                huds.count == 1,
                let hud = huds.first
                where hud.labelText == title
            {
                return false
            }
        }
        return true
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
        delegate?.vipGateExitedWithSuccess(true)
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
        
        if let color = dependencyManager.descriptionTextColor {
            detailLabel.textColor = color
        }
        if let font = dependencyManager.descriptionFont {
            detailLabel.font = font
        }
        
        subscribeButton.dependencyManager = dependencyManager.subscribeButtonDependency
        restoreButton.dependencyManager = dependencyManager.restoreButtonDependency
    }
    
    override func updateViewConstraints() {
        let inset = scrollViewInsetConstraints.reduce(0, combine: { $0 + $1.constant })
        labelWidthConstraint.constant = view.bounds.width - inset
        super.updateViewConstraints()
    }
    
    // MARK: - VIPSubscriptionHelperDelegate
    
    func VIPSubscriptionHelperCompletedSubscription(helper: VIPSubscriptionHelper) {
        openGate()
    }
    
    func setIsLoading(isLoading: Bool, title: String? = nil) {
        if isLoading {
            guard HUDNeedsUpdateToTitle(title) else {
                return
            }
            MBProgressHUD.hideAllHUDsForView(self.view, animated: false)
            let progressHUD = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
            progressHUD.mode = .Indeterminate
            progressHUD.labelText = title
        } else {
            MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
        }
    }
    
    // MARK: - String Constants
    
    private struct Strings {
        static let privacyPolicy            = NSLocalizedString("Privacy Policy", comment: "")
        static let termsOfService           = NSLocalizedString("Terms of Service", comment: "")
        static let restoreFailed            = NSLocalizedString("SubscriptionRestoreFailed", comment: "")
        static let restoreInProgress        = NSLocalizedString("SubscriptionActivityRestoring", comment: "")
        static let restorePrompt            = NSLocalizedString("SubscriptionRestorePrompt", comment: "")
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
    
    func descriptionText(for products: [VProduct]) -> String? {
        guard let description = stringForKey("text.description") else {
            return nil
        }
        
        guard let lowestPriceProduct = products.select({ $1.storeKitProduct?.price.doubleValue < $0.storeKitProduct?.price.doubleValue }) else {
            return nil
        }
        
        return description.stringByReplacingOccurrencesOfString("%%PRICE_TAG%%", withString: lowestPriceProduct.price)
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
        guard
            let font = fontForKey("font.tos"),
            let color = colorForKey("color.tos")
        else {
                return nil
        }
        
        return [
            NSFontAttributeName: font,
            NSForegroundColorAttributeName: color
        ]
    }
    
    var termsOfService: String? {
        return stringForKey("text.tos")
    }
    
    var privacyPolicyLinkAttributes: [String : AnyObject]? {
        guard
            let font = fontForKey("font.privacy"),
            let color = colorForKey("color.privacy")
        else {
                return nil
        }
        
        return [
            NSFontAttributeName: font,
            NSForegroundColorAttributeName: color
        ]
    }
    
    var privacyPolicyText: String? {
        return stringForKey("text.privacy")
    }
    
    var subscribeButtonDependency: VDependencyManager? {
        return childDependencyForKey("subscribeButton")
    }
    
    var closeButtonDependency: VDependencyManager? {
        return childDependencyForKey("close.button")
    }
    
    var restoreButtonDependency: VDependencyManager? {
        return childDependencyForKey("restore.button")
    }
    
    var subscriptionFetchURL: String? {
        return networkResources?.stringForKey("inapp.sku.URL")
    }
    
    var validationURL: NSURL? {
        guard
            let urlString = networkResources?.stringForKey("purchaseURL"),
            let url = NSURL(string: urlString)
        else {
            return nil
        }
        return url
    }
}
