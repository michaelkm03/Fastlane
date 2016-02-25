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
    let transitionDelegate = VTransitionDelegate(transition: VSimpleModalTransition())

    //MARK: - Initialization

    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?, dependencyManager: VDependencyManager) {
        self.dependencyManager = dependencyManager
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    //MARK: - View Lifecycle

    override func viewDidLoad() {
        if VCurrentUser.user()?.isVIPSubscriber == true {
            setUpVIPViews()
        } else {
            showPurchaseSubscriptionScreen()
        }
    }

    private func setUpVIPViews() {
        let alert = UIAlertController(title: "Yay!", message: "You're now in the VIP zone", preferredStyle: .Alert)
        presentViewController(alert, animated: true, completion: nil)
    }

    private func showPurchaseSubscriptionScreen() {
        let purchaseViewController = VPurchaseViewController.newWithDependencyManager(self.dependencyManager,
            productIdentifier: kTestSubscriptionProductIdentifier,
            largeIcon: kLargeSubscribeImage)
        purchaseViewController.transitioningDelegate = self.transitionDelegate
        purchaseViewController.delegate = self
        self.presentViewController(purchaseViewController, animated: true, completion: nil)
    }

    //MARK: - VPurchaseViewControllerDelegate

    func purchaseDidFinish(didMakePurchase: Bool) {
        if didMakePurchase == true {
            self.presentedViewController?.dismissViewControllerAnimated(true) {
                self.setUpVIPViews()
            }
        }
    }
}
