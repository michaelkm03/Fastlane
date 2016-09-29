//
//  VIPFlowNavigationController.swift
//  victorious
//
//  Created by Sharif Ahmed on 5/23/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

typealias VIPFlowCompletion = ((Bool) -> ())

class VIPFlowNavigationController: UINavigationController, VIPGateViewControllerDelegate, VIPSuccessViewControllerDelegate, VBackgroundContainer {
    let animationDelegate: CrossFadingNavigationControllerDelegate = {
        let delegate = CrossFadingNavigationControllerDelegate()
        delegate.fadingEnabled = false
        return delegate
    }()
    var completionBlock: VIPFlowCompletion?
    @objc fileprivate(set) var dependencyManager: VDependencyManager!
    fileprivate var gateDependencyManager: VDependencyManager!
    fileprivate var successDependencyManager: VDependencyManager!
    
    class func new(with dependencyManager: VDependencyManager) -> VIPFlowNavigationController? {
        guard
            dependencyManager.isVIPEnabled == true,
            let gateDependencyManager = dependencyManager.paygateDependency,
            let successDependencyManager = dependencyManager.successDependency
            , VCurrentUser.user != nil
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        dependencyManager.trackViewWillAppear(for: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        dependencyManager.trackViewWillDisappear(for: self)
    }

    // MARK: - VBackgroundContainer

    func backgroundContainerView() -> UIView {
        return view
    }
    
    // MARK: - VIPGateViewControllerDelegate
    
    func vipGateExitedWithSuccess(_ success: Bool) {
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
    
    func successViewControllerFinished(_ successViewController: VIPSuccessViewController) {
        dismissAndCallCompletionWithSuccess(true)
    }
    
    // MARK: - Delegate notification
    
    func dismissAndCallCompletionWithSuccess(_ success: Bool) {
        
        presentingViewController?.dismiss(animated: true) { [weak self] in
            self?.completionBlock?(success)
        }
    }
    
    // MARK: - rotation management
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return .portrait
    }
}

private extension VDependencyManager {
    var backgroundImage: UIImage? {
        return image(forKey: "backgroundImage")
    }
    
    var successDependency: VDependencyManager? {
        return childDependency(forKey: "success")
    }
    
    var paygateDependency: VDependencyManager? {
        return childDependency(forKey: "vipPaygate")
    }
}
