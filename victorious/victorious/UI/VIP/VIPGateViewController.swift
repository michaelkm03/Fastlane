//
//  VIPGateViewController.swift
//  victorious
//
//  Created by Patrick Lynch on 3/4/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit
import MBProgressHUD
import VictoriousIOSSDK

/// Conformers will receive a message when the vip gate
/// will dismiss or has permitted the user to pass through.
protocol VIPGateViewControllerDelegate: class {
    func vipGateExitedWithSuccess(_ success: Bool)
    
    /// Presents a VIP flow on the scaffold using values found in the provided dependency manager.
    func showVIPForumFromDependencyManager(_ dependencyManager: VDependencyManager)
}

extension VIPGateViewControllerDelegate {
    func showVIPForumFromDependencyManager(_ dependencyManager: VDependencyManager) {
        guard let scaffold = VRootViewController.shared()?.scaffold else {
            return
        }
        let router = Router(originViewController: scaffold, dependencyManager: dependencyManager)
        router.navigate(to: .vipForum, from: nil)
    }
}

class VIPGateViewController: UIViewController, VIPSubscriptionHelperDelegate {
    @IBOutlet weak fileprivate var headlineLabel: UILabel!
    @IBOutlet weak fileprivate var detailLabel: UILabel!
    @IBOutlet weak fileprivate var subscribeButton: TextOnColorButton!
    @IBOutlet weak fileprivate var restoreButton: TextOnColorButton!
    @IBOutlet weak fileprivate var privacyPolicyButton: UIButton!
    @IBOutlet weak fileprivate var termsOfServiceButton: UIButton!
    @IBOutlet weak fileprivate var closeButton: ImageOnColorButton! {
        didSet {
            closeButton.dependencyManager = dependencyManager.closeButtonDependency
            closeButton.touchInsets = UIEdgeInsetsMake(-12, -12, -12, -12)
        }
    }
    
    @IBOutlet fileprivate var labelWidthConstraint: NSLayoutConstraint!
    @IBOutlet fileprivate var scrollViewInsetConstraints: [NSLayoutConstraint]!
    
    fileprivate lazy var vipSubscriptionHelper: VIPSubscriptionHelper? = {
        guard let subscriptionFetchAPIPath = self.dependencyManager.subscriptionFetchAPIPath else {
            return nil
        }
        
        return VIPSubscriptionHelper(subscriptionFetchAPIPath: subscriptionFetchAPIPath, delegate: self, originViewController: self, dependencyManager: self.dependencyManager)
    }()
    
    weak var delegate: VIPGateViewControllerDelegate?
        
    var dependencyManager: VDependencyManager! {
        didSet {
            updateViews()
        }
    }

    // MARK: - Initialization

    class func new(with dependencyManager: VDependencyManager) -> VIPGateViewController {
        let viewController: VIPGateViewController = VIPGateViewController.v_initialViewControllerFromStoryboard()
        viewController.dependencyManager = dependencyManager
        viewController.title = dependencyManager.string(forKey: "title")
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
    
    @IBAction func onSubscribe(_ sender: UIButton? = nil) {
        subscribeButton.dependencyManager?.trackButtonEvent(.tap)
        vipSubscriptionHelper?.subscribe()
    }
    
    @IBAction func onRestore(_ sender: UIButton? = nil) {
        restoreButton.dependencyManager?.trackButtonEvent(.tap)
        
        guard let validationAPIPath = dependencyManager.validationAPIPath else {
            return
        }
        
        let restore = RestorePurchasesOperation(validationAPIPath: validationAPIPath)
        
        setIsLoading(true, title: Strings.restoreInProgress)
        
        restore.queue { [weak self] result in
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
        navigateToFixedWebContent(.privacyPolicy)
    }
    
    @IBAction func onTermsOfServiceSelected() {
        navigateToFixedWebContent(.termsOfService)
    }
    
    @IBAction func onCloseSelected() {
        closeButton.dependencyManager?.trackButtonEvent(.cancel)
        delegate?.vipGateExitedWithSuccess(false)
    }
    
    // MARK: - Private
    
    fileprivate func navigateToFixedWebContent(_ type: FixedWebContentType) {
        let router = Router(originViewController: self, dependencyManager: dependencyManager.navBarDependency)
        let configuration = ExternalLinkDisplayConfiguration(addressBarVisible: false, forceModal: true, isVIPOnly: false, title: type.title)
        router.navigate(to: .externalURL(url: dependencyManager.urlForFixedWebContent(type) as URL, configuration: configuration), from: nil)
    }
    
    fileprivate func HUDNeedsUpdateToTitle(_ title: String?) -> Bool {
        if let currentTitle = progressHUD.labelText , currentTitle == title {
            return false
        }
        else {
            return true
        }
    }
    
    fileprivate func openGate() {
        delegate?.vipGateExitedWithSuccess(true)
    }
    
    fileprivate func updateViews() {
        guard isViewLoaded else {
            return
        }
        
        let privacyPolicyText = NSMutableAttributedString(
            string: dependencyManager.privacyPolicyText ?? Strings.privacyPolicy
        )
        if let attributes = dependencyManager.privacyPolicyLinkAttributes {
            privacyPolicyText.addAttributes(attributes, range: NSMakeRange(0, privacyPolicyText.length))
        }
        privacyPolicyButton.setAttributedTitle(privacyPolicyText, for: .normal)
        
        let termsOfServiceText = NSMutableAttributedString(
            string: dependencyManager.termsOfService ?? Strings.termsOfService
        )
        if let attributes = dependencyManager.termsOfServiceLinkAttributes {
            termsOfServiceText.addAttributes(attributes, range: NSMakeRange(0, termsOfServiceText.length))
        }
        termsOfServiceButton.setAttributedTitle(termsOfServiceText, for: .normal)
        
        restoreButton.setTitle(dependencyManager.restoreText ?? Strings.restorePrompt, for: .normal)
        restoreButton.setTitleColor(dependencyManager.restoreTextColor, for: .normal)
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
        let inset = scrollViewInsetConstraints.reduce(0, { $0 + $1.constant })
        labelWidthConstraint.constant = view.bounds.width - inset
        super.updateViewConstraints()
    }
    
    // MARK: - VIPSubscriptionHelperDelegate
    
    func VIPSubscriptionHelperCompletedSubscription(_ helper: VIPSubscriptionHelper) {
        openGate()
    }
    
    fileprivate lazy var progressHUD: MBProgressHUD = {
        let progressHUD = MBProgressHUD(for: self.view)!
        progressHUD.mode = .indeterminate
        progressHUD.graceTime = 0.35
        
        self.view.addSubview(progressHUD)
        
        return progressHUD
    }()
    
    func setIsLoading(_ isLoading: Bool, title: String? = nil) {
        if isLoading {
            guard HUDNeedsUpdateToTitle(title) else {
                return
            }
            progressHUD.labelText = title
            progressHUD.taskInProgress = true
            progressHUD.show(true)
        } else {
            progressHUD.taskInProgress = false
            progressHUD.hide(true)
        }
    }
    
    // MARK: - String Constants
    
    fileprivate struct Strings {
        static let privacyPolicy            = NSLocalizedString("Privacy Policy", comment: "")
        static let termsOfService           = NSLocalizedString("Terms of Service", comment: "")
        static let restoreFailed            = NSLocalizedString("SubscriptionRestoreFailed", comment: "")
        static let restoreInProgress        = NSLocalizedString("SubscriptionActivityRestoring", comment: "")
        static let restorePrompt            = NSLocalizedString("SubscriptionRestorePrompt", comment: "")
    }
}

private extension VDependencyManager {
    var navBarDependency: VDependencyManager {
        return childDependency(forKey: "navigation.bar.appearance") ?? self
    }
    
    var headerText: String? {
        return string(forKey: "text.header")
    }
    
    var headerFont: UIFont? {
        return font(forKey: "font.header")
    }
    
    var headerTextColor: UIColor? {
        return color(forKey: "color.header")
    }
    
    func descriptionText(for products: [VProduct]) -> String? {
        guard let description = string(forKey: "text.description") else {
            return nil
        }
        
        guard let lowestPriceProduct = products.select({ ($1.storeKitProduct?.price.doubleValue ?? 0.0) < ($0.storeKitProduct?.price.doubleValue ?? 0.0) }) else {
            return nil
        }
        
        return description.replacingOccurrences(of: "%%PRICE_TAG%%", with: lowestPriceProduct.price)
    }
    
    var descriptionFont: UIFont? {
        return font(forKey: "font.description")
    }
    
    var descriptionTextColor: UIColor? {
        return color(forKey: "color.description")
    }
    
    var restoreText: String? {
        return string(forKey: "text.restore")
    }
    
    var restoreFont: UIFont? {
        return font(forKey: "font.restore")
    }
    
    var restoreTextColor: UIColor? {
        return color(forKey: "color.restore")
    }
    
    var termsOfServiceLinkAttributes: [String: AnyObject]? {
        guard
            let font = font(forKey: "font.tos"),
            let color = color(forKey: "color.tos")
        else {
            return nil
        }
        
        return [
            NSFontAttributeName: font,
            NSForegroundColorAttributeName: color
        ]
    }
    
    var termsOfService: String? {
        return string(forKey: "text.tos")
    }
    
    var privacyPolicyLinkAttributes: [String : AnyObject]? {
        guard
            let font = font(forKey: "font.privacy"),
            let color = color(forKey: "color.privacy")
        else {
            return nil
        }
        
        return [
            NSFontAttributeName: font,
            NSForegroundColorAttributeName: color
        ]
    }
    
    var privacyPolicyText: String? {
        return string(forKey: "text.privacy")
    }
    
    var subscribeButtonDependency: VDependencyManager? {
        return childDependency(forKey: "subscribeButton")
    }
    
    var closeButtonDependency: VDependencyManager? {
        return childDependency(forKey: "close.button")
    }
    
    var restoreButtonDependency: VDependencyManager? {
        return childDependency(forKey: "restore.button")
    }
    
    var subscriptionFetchAPIPath: APIPath? {
        return networkResources?.apiPath(forKey: "inapp.sku.URL")
    }
    
    var validationAPIPath: APIPath? {
        return networkResources?.apiPath(forKey: "purchaseURL")
    }
}
