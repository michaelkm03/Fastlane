//
//  VIPViewController.swift
//  victorious
//
//  Created by Alex Tamoykin on 2/24/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

class VIPViewController: UIViewController, VPurchaseViewControllerDelegate {
    let kLargeSubscribeImage = UIImage(named: "test_vip_icon_large")!
    let dependencyManager: VDependencyManager
    let purchaseManager: VPurchaseManager
    let transitionDelegate = VTransitionDelegate(transition: VSimpleModalTransition())
    let subscriptionSettings: SubscriptionSettings

    //MARK: - Initialization

    class func newWithDependencyManager(dependencyManager: VDependencyManager) -> VIPViewController {
        return VIPViewController(nibName: nil,
            bundle: nil,
            dependencyManager: dependencyManager,
            purchaseManager: VPurchaseManager.sharedInstance(),
            subscriptionSettings: SubscriptionSettings(dependencyManager: dependencyManager)
        )
    }

    init(nibName nibNameOrNil: String?,
        bundle nibBundleOrNil: NSBundle?,
        dependencyManager: VDependencyManager,
        purchaseManager: VPurchaseManager,
        subscriptionSettings: SubscriptionSettings) {

            self.dependencyManager = dependencyManager
            self.purchaseManager = purchaseManager
            self.subscriptionSettings = subscriptionSettings
            super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    //MARK: - View Lifecycle

    override func viewDidLoad() {
        self.view.backgroundColor = UIColor.magentaColor()

        if VCurrentUser.user()?.isVIPSubscriber == true {
            let receipt = NSBundle.mainBundle().readReceiptData()
            purchaseManager.validateReceipt(receipt,
                success: { isReceiptValid in
                    if isReceiptValid == true {
                        self.setUpVIPViews()
                    } else {
                        let alert = UIAlertController(title: "Invalid subscription",
                            message: "Your subscription became invalid",
                            preferredStyle: .Alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                        self.presentViewController(alert, animated: true, completion: nil)
                        self.showPurchaseSubscriptionScreen()
                    }
                }, failure: { error in
                    VLog("Failed to validate a receipt when entering the VIP screen")
                }
            )
        } else {
            showPurchaseSubscriptionScreen()
        }
    }

    private func setUpVIPViews() {
        let alert = UIAlertController(title: "Yay!", message: "You're now in the VIP zone", preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Awesome!", style: .Default, handler: nil))
        presentViewController(alert, animated: true, completion: nil)
    }

    private func showPurchaseSubscriptionScreen() {
        guard let productIdentifier = subscriptionSettings.getProductIdentifier() else {
            fatalError("There should alway be a subscription product identifier when showing a VIP screen")
        }
        let purchaseViewController = VPurchaseViewController.newWithDependencyManager(self.dependencyManager,
            productIdentifier: productIdentifier,
            largeIcon: kLargeSubscribeImage)
        purchaseViewController.transitioningDelegate = self.transitionDelegate
        purchaseViewController.delegate = self
        self.presentViewController(purchaseViewController, animated: true, completion: nil)
    }

    //MARK: - VPurchaseViewControllerDelegate

    func purchaseDidFinish(didMakePurchase: Bool) {
        if didMakePurchase == true {
            self.presentedViewController?.dismissViewControllerAnimated(true) {
                VCurrentUser.user()?.isVIPSubscriber = true
                self.setUpVIPViews()
            }
        } else {
            self.presentedViewController?.dismissViewControllerAnimated(true, completion: nil)
        }
    }
}
