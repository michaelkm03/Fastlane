//
//  VIPGateViewController.swift
//  victorious
//
//  Created by Patrick Lynch on 3/4/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

class VIPGateViewController: UIViewController {
    
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

        /*if VCurrentUser.user()?.isVIPSubscriber == true {
            let receipt = NSBundle.mainBundle().v_readReceiptData()
            purchaseManager.validateReceipt(receipt,
                success: { isReceiptValid in
                    if isReceiptValid == true {
                        self.setUpVIPViews()
                    } else {
                        self.onSubscriptionInvalid()
                    }
                }, failure: { error in
                    VLog("Failed to validate a receipt when entering the VIP screen")
                }
            )
        }*/
    }
    
    // MARK: - IBActions
    
    @IBAction func onSubscribe(sender: UIButton) {
        let productIdentifier = dependencyManager.subscriptionProductIdentifier
        VPurchaseManager.sharedInstance().purchaseProductWithIdentifier(productIdentifier,
            success: { results in
                print("onSubscribe :: success")
                VCurrentUser.user()?.isVIPSubscriber = true
            },
            failure: { error in
                print("onSubscribe :: error: \(error)")
            }
        )
    }
    
    @IBAction func onRestore(sender: UIButton) {
        VPurchaseManager.sharedInstance().restorePurchasesSuccess({ results in
                print("onRestore :: success")
            },
            failure: { error in
                print("onRestore :: error: \(error)")
            }
        )
    }
    
    // MARK: - Private
    
    private func onSubscriptionInvalid() {
        let alert = UIAlertController(title: "Invalid subscription",
            message: "Your subscription became invalid",
            preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        presentViewController(alert, animated: true, completion: nil)
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
}
