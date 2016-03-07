//
//  VIPGateViewController.swift
//  victorious
//
//  Created by Patrick Lynch on 3/4/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

class VIPGateViewController: UIViewController, VNavigationDestination {
    
    let transitionDelegate = VTransitionDelegate(transition: VSimpleModalTransition())
    
    @IBOutlet weak private var textView: UITextView!
    @IBOutlet weak private var subscribeButton: UIButton!
    @IBOutlet weak private var restoreButton: UIButton!
    @IBOutlet weak private var activityIndicator: UIActivityIndicatorView!
    
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
        validate()
    }
    
    var isValidating: Bool = false {
        didSet {
            if isValidating {
                textView.hidden = true
                subscribeButton.hidden = true
                restoreButton.hidden = true
                activityIndicator.hidden = false
            } else {
                textView.hidden = false
                subscribeButton.hidden = false
                restoreButton.hidden = false
                activityIndicator.hidden = true
            }
        }
    }
    
    func onSubcriptionValidated() {
        if VCurrentUser.user()!.isVIPSubscriber.boolValue {
            print( "Validation succeeded!" )
        } else {
            print( "Validation failed!" )
        }
    }
    
    func validate() {
        isValidating = true
        VIPValidateOperation().queue() { results, error in
            self.isValidating = false
            if let error = error {
                let title = "VIP Validation Failed"
                let message = error.localizedDescription
                self.v_showErrorWithTitle(title, message: message)
            } else {
                self.onSubcriptionValidated()
            }
        }
    }
    
    // MARK: - IBActions
    
    @IBAction func onSubscribe(sender: UIButton? = nil) {
        let productIdentifier = dependencyManager.subscriptionProductIdentifier!
        let subscribe = VIPSubscribeOperation(productIdentifier: productIdentifier)
        subscribe.queue() { op in
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
        restore.queue() { op in
            if let error = restore.error {
                let title = "VIP Restore Subscription Failed"
                let message = error.localizedDescription
                self.v_showErrorWithTitle(title, message: message)
            } else {
                self.validate()
            }
        }
    }
    
    // MARK: - Private
    
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
        
        let vc = UIViewController()
        vc.view.backgroundColor = UIColor.redColor()
        alternateViewController.memory = vc
        
        return true
    }
}
