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
    
    lazy var vipIconView: UIView = {
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
        let viewController: VIPGateViewController = VIPGateViewController.v_initialViewControllerFromStoryboard()
        viewController.dependencyManager = dependencyManager
        viewController.title = dependencyManager.stringForKey("title")
        return viewController
    }

    //MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        edgesForExtendedLayout = .Bottom
        extendedLayoutIncludesOpaqueBars = true
        automaticallyAdjustsScrollViewInsets = false
        
        updateViews()
    }
    
    func setIsLoading(isLoading: Bool, title: String? = nil) {
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
    
    // MARK: - IBActions
    
    @IBAction func onSubscribe(sender: UIButton? = nil) {
        let productIdentifier = dependencyManager.subscriptionProductIdentifier!
        let subscribe = VIPSubscribeOperation(productIdentifier: productIdentifier)
        setIsLoading(true, title: NSLocalizedString("ActivityPurchasing", comment:""))
        subscribe.queue() { op in
            self.setIsLoading(false)
            if let error = subscribe.error {
                let title = "VIP Subscription Failed"
                let message = error.localizedDescription
                self.v_showErrorWithTitle(title, message: message)
            } else {
                self.onSubcriptionValidated()
            }
        }
    }
    
    @IBAction func onRestore(sender: UIButton? = nil) {
        let restore = RestorePurchasesOperation()
        setIsLoading(true, title: NSLocalizedString("ActivityRestoring", comment:""))
        restore.queue() { op in
            self.setIsLoading(false)
            if let error = restore.error {
                let title = "VIP Restore Subscription Failed"
                let message = error.localizedDescription
                self.v_showErrorWithTitle(title, message: message)
            }
        }
    }
    
    // MARK: - Private
    
    private func onSubcriptionValidated() {
        guard VCurrentUser.user()?.isVIPSubscriber.boolValue ?? false else {
            v_showErrorWithTitle("Validation Failed", message: "The current user has not been verifed as a VIP member.")
            return
        }
        
        MBProgressHUD.hideAllHUDsForView(self.view, animated: false)
        let progressHUD = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        progressHUD.mode = .CustomView
        progressHUD.customView = vipIconView
        progressHUD.labelText = "Success!"
        
        dispatch_after(1.0) {
            MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
            self.openGate()
        }
    }
    
    private func openGate() {
        guard let rootViewController = VRootViewController.sharedRootViewController() else {
            assertionFailure()
            return
        }
        
        // WARNING: Temporyary for testing only until a Forum view controller is avialabl
        let vc = UIViewController()
        vc.view.backgroundColor = UIColor.redColor()
        vc.view.addGestureRecognizer( UITapGestureRecognizer(target: self, action: "exit") )
        rootViewController.presentViewController(vc, animated: true) {
            self.dependencyManager.scaffoldViewController()?.setSelectedMenuItemAtIndex(0)
        }
    }
    
    // WARNING: Temporyary for testing only until a Forum view controller is avialable
    func exit() {
        guard let rootViewController = VRootViewController.sharedRootViewController() else {
            assertionFailure()
            return
        }
        rootViewController.dismissViewControllerAnimated(true, completion: nil)
    }
    
    private func updateViews() {
        guard isViewLoaded() else {
            return
        }
        
        subscribeButton.setTitle(dependencyManager.subscribeText, forState: .Normal)
        subscribeButton.titleLabel?.font = dependencyManager.subscribeFont
        subscribeButton.backgroundColor = dependencyManager.subscribeColor
        
        textView.text = dependencyManager.greetingText
        textView.font = dependencyManager.greetingFont
        textView.textColor = dependencyManager.greetingColor
    }
    
    // MARK: - VNavigationDestination
    
    func shouldNavigateWithAlternateDestination(alternateViewController: AutoreleasingUnsafeMutablePointer<AnyObject?>) -> Bool {
        
        if let currentUser = VCurrentUser.user() where currentUser.isVIPSubscriber.boolValue {
            openGate()
            return false
        }
        
        return true
    }
}
