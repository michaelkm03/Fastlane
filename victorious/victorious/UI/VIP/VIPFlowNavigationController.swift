//
//  VIPFlowNavigationController.swift
//  victorious
//
//  Created by Sharif Ahmed on 5/23/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

@objc(VIPFlowNavigationController)
class VIPFlowNavigationController: UINavigationController, VIPGateViewControllerDelegate, VIPSuccessViewControllerDelegate, VBackgroundContainer, VNavigationDestination {
    
    @objc private(set) var dependencyManager: VDependencyManager!
    
    class func newWithDependencyManager(dependencyManager: VDependencyManager) -> VIPFlowNavigationController {
        
        let vipFlow: VIPFlowNavigationController = v_initialViewControllerFromStoryboard()
        vipFlow.dependencyManager = dependencyManager
        let vipGate: VIPGateViewController = VIPGateViewController.newWithDependencyManager(dependencyManager)
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
    
    var backgroundImage: UIImage? {
        return imageForKey("backgroundImage")
    }
}
