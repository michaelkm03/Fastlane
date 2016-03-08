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
    
    let transitionDelegate = VTransitionDelegate(transition: VSimpleModalTransition())
    
    @IBOutlet weak private var textView: UITextView!
    @IBOutlet weak private var subscribeButton: UIButton!
    @IBOutlet weak private var restoreButton: UIButton!
    
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
    
    func onSubcriptionValidated() {
        if VCurrentUser.user()!.isVIPSubscriber.boolValue {
            print( "Validation succeeded!" )
        } else {
            print( "Validation failed!" )
        }
        openGate()
    }
    
    var isLoading: Bool = false {
        didSet {
            if isLoading {
                MBProgressHUD.hideAllHUDsForView(self.view, animated: false)
                let customView = UIImageView(image: UIImage(named:"error")!.imageWithRenderingMode(.AlwaysTemplate))
                customView.tintColor = UIColor.whiteColor()
                
                let progressHUD = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
                progressHUD.mode = .CustomView
                progressHUD.customView = customView
                progressHUD.labelText = "   Purchasing subscription..."
            } else {
                MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
            }
        }
    }
    
    // MARK: - IBActions
    
    @IBAction func onSubscribe(sender: UIButton? = nil) {
        let productIdentifier = dependencyManager.subscriptionProductIdentifier!
        let subscribe = VIPSubscribeOperation(productIdentifier: productIdentifier)
        self.isLoading = true
        subscribe.queue() { op in
            self.isLoading = false
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
        self.isLoading = true
        restore.queue() { op in
            self.isLoading = false
            if let error = restore.error {
                let title = "VIP Restore Subscription Failed"
                let message = error.localizedDescription
                self.v_showErrorWithTitle(title, message: message)
            }
        }
    }
    
    // MARK: - Private
    
    func exit() {
        guard let rootViewController = VRootViewController.sharedRootViewController() else {
            assertionFailure()
            return
        }
        rootViewController.dismissViewControllerAnimated(true, completion: nil)
    }
    
    private func openGate() {
        guard let rootViewController = VRootViewController.sharedRootViewController() else {
            assertionFailure()
            return
        }
        
        let vc = UIViewController()
        vc.view.backgroundColor = UIColor.redColor()
        vc.view.addGestureRecognizer( UITapGestureRecognizer(target: self, action: "exit") )
        rootViewController.presentViewController(vc, animated: true) {
            self.dependencyManager.scaffoldViewController()?.setSelectedMenuItemAtIndex(0)
        }
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
