//
//  VIPFlowNavigationController.swift
//  victorious
//
//  Created by Sharif Ahmed on 5/23/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

typealias VIPFlowCompletion = (Bool -> ())

class VIPFlowNavigationController: UINavigationController, VIPGateViewControllerDelegate, VIPSuccessViewControllerDelegate, VBackgroundContainer {
    let animationDelegate: CrossFadingNavigationControllerDelegate = {
        let delegate = CrossFadingNavigationControllerDelegate()
        delegate.fadingEnabled = false
        return delegate
    }()
    var completionBlock: VIPFlowCompletion?
    @objc private(set) var dependencyManager: VDependencyManager!
    private var gateDependencyManager: VDependencyManager!
    private var successDependencyManager: VDependencyManager!
    
    class func newWithDependencyManager(dependencyManager: VDependencyManager) -> VIPFlowNavigationController? {
        guard
            dependencyManager.isVIPEnabled == true,
            let gateDependencyManager = dependencyManager.paygateDependency,
            let successDependencyManager = dependencyManager.successDependency
            where VCurrentUser.isLoggedIn()
        else {
            return nil
        }
        
        let vipFlow: VIPFlowNavigationController = v_initialViewControllerFromStoryboard()
        vipFlow.dependencyManager = dependencyManager
        vipFlow.gateDependencyManager = gateDependencyManager
        vipFlow.successDependencyManager = successDependencyManager
        let vipGate = VIPGateViewController.newWithDependencyManager(gateDependencyManager)
        vipGate.delegate = vipFlow
        vipFlow.showViewController(vipGate, sender: nil)
        return vipFlow
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        gateDependencyManager?.addBackgroundToBackgroundHost(self)
        delegate = animationDelegate
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        dependencyManager.trackViewWillAppear(self)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        dependencyManager.trackViewWillDisappear(self)
    }

    // MARK: - VBackgroundContainer

    func backgroundContainerView() -> UIView {
        return view
    }
    
    // MARK: - VIPGateViewControllerDelegate
    
    func vipGateExitedWithSuccess(success: Bool, afterPurchase purchased: Bool) {
        if success {
            //Transition to success state
            animationDelegate.fadingEnabled = true
            let successViewController = VIPSuccessViewController.newWithDependencyManager(successDependencyManager)
            successViewController.delegate = self
            showViewController(successViewController, sender: nil)
        }
        else {
            dismissAndCallCompletionWithSuccess(success)
        }
    }
    
    // MARK: - VIPSuccessViewControllerDelegate
    
    func successViewControllerFinished(successViewController: VIPSuccessViewController) {
        dismissAndCallCompletionWithSuccess(true)
    }
    
    // MARK: - Delegate notification
    
    func dismissAndCallCompletionWithSuccess(success: Bool) {
        
        presentingViewController?.dismissViewControllerAnimated(true) { [weak self] in
            self?.completionBlock?(success)
        }
    }
    
    // MARK: - rotation management
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return .Portrait
    }
}

private extension VDependencyManager {
    var backgroundImage: UIImage? {
        return imageForKey("backgroundImage")
    }
    
    var successDependency: VDependencyManager? {
        return childDependencyForKey("success")
    }
    
    var paygateDependency: VDependencyManager? {
        return childDependencyForKey("vipPaygate")
    }
}
