//
//  VIPFlowNavigationController.swift
//  victorious
//
//  Created by Sharif Ahmed on 5/23/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

protocol VIPFlowNavigationControllerDelegate: class {
    func VIPFlowNaivigationController(navigationController: VIPFlowNavigationController, completedFlowWithSuccess success: Bool)
}

class VIPFlowNavigationController: UINavigationController, VIPGateViewControllerDelegate, VIPSuccessViewControllerDelegate, VBackgroundContainer, VNavigationDestination {
    let animationDelegate = CrossFadingNavigationControllerDelegate()
    
    weak var flowDelegate: VIPFlowNavigationControllerDelegate? {
        didSet {
            guard
                let user = VCurrentUser.user()
                where user.isVIPSubscriber == false
            else {
                flowDelegate?.VIPFlowNaivigationController(self, completedFlowWithSuccess: true)
                return
            }
        }
    }
    
    @objc private(set) var dependencyManager: VDependencyManager!
    
    private var gateDependencyManager: VDependencyManager!
    
    private var successDependencyManager: VDependencyManager!
    
    class func newWithDependencyManager(dependencyManager: VDependencyManager) -> VIPFlowNavigationController? {
        guard
            dependencyManager.isVIPEnabled == true,
            let gateDependencyManager = dependencyManager.paygateDependency,
            let successDependencyManager = dependencyManager.successDependency,
            let _ = VCurrentUser.user()
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

    // MARK: - VBackgroundContainer

    func backgroundContainerView() -> UIView {
        return view
    }
    
    // MARK: - VIPGateViewControllerDelegate
    
    func vipGateExitedWithSuccess(success: Bool, afterPurchase purchased: Bool) {
        
        if success && purchased {
            //Transition to success state
            let successViewController = VIPSuccessViewController.newWithDependencyManager(successDependencyManager)
            successViewController.delegate = self
            showViewController(successViewController, sender: nil)
        } else {
            let shouldAnimate = !(success || purchased)
            presentingViewController?.dismissViewControllerAnimated(shouldAnimate, completion: nil)
        }
    }
    
    // MARK: - VIPSuccessViewControllerDelegate
    
    func successViewControllerFinished(successViewController: VIPSuccessViewController) {
        flowDelegate?.VIPFlowNaivigationController(self, completedFlowWithSuccess: true)
        presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
}

private extension VDependencyManager {
    var isVIPEnabled: Bool? {
        return vipSubscription?.enabled
    }
    
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
