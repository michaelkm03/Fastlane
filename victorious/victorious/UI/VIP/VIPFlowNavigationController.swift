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

@objc(VIPFlowNavigationController)
class VIPFlowNavigationController: UINavigationController, VIPGateViewControllerDelegate, VIPSuccessViewControllerDelegate, VBackgroundContainer, VNavigationDestination {
    
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
    
    class func newWithDependencyManager(dependencyManager: VDependencyManager) -> VIPFlowNavigationController? {
        guard
            dependencyManager.isVIPEnabled == true,
            let _ = VCurrentUser.user()
        else {
            return nil
        }
        
        let vipFlow: VIPFlowNavigationController = v_initialViewControllerFromStoryboard()
        vipFlow.dependencyManager = dependencyManager
        let vipGate = VIPGateViewController.newWithDependencyManager(dependencyManager)
        vipGate.delegate = vipFlow
        vipFlow.showViewController(vipGate, sender: nil)
        return vipFlow
    }

    // MARK: - VBackgroundContainer

    func backgroundContainerView() -> UIView {
        return view
    }
    
    // MARK: - VIPGateViewControllerDelegate
    
    func vipGateExitedWithSuccess(success: Bool, afterPurchase purchased: Bool) {
        
        if success && purchased {
            //Transition to success state
            let successViewController = VIPSuccessViewController.newWithDependencyManager(dependencyManager)
            successViewController.delegate = self
            showViewController(successViewController, sender: nil)
        } else {
            let shouldAnimate = !(success || purchased)
            presentingViewController?.dismissViewControllerAnimated(shouldAnimate, completion: nil)
        }
    }
    
    // MARK: - VIPSuccessViewControllerDelegate
    
    func successViewControllerFinished(successViewController: VIPSuccessViewController) {
        presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
}

private extension VDependencyManager {
    var isVIPEnabled: Bool? {
        return numberForKey("is_vip_enabled")?.boolValue
    }
    
    var backgroundImage: UIImage? {
        return imageForKey("backgroundImage")
    }
}
