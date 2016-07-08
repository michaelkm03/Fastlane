//
//  ShowVIPFlowOperation.swift
//  victorious
//
//  Created by Jarod Long on 5/10/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

class ShowVIPFlowOperation: MainQueueOperation, VIPFlowNavigationControllerDelegate {
    private let dependencyManager: VDependencyManager
    private let animated: Bool
    private weak var originViewController: UIViewController?
    private(set) var showedGate = false
    private(set) var allowedAccess = false
    
    required init(originViewController: UIViewController, dependencyManager: VDependencyManager, animated: Bool = true) {
        self.dependencyManager = dependencyManager
        self.originViewController = originViewController
        self.animated = animated
    }
    
    override func start() {
        guard
            !cancelled,
            let originViewController = originViewController,
            let vipFlow = dependencyManager.templateValueOfType(VIPFlowNavigationController.self, forKey: "vipPaygateScreen") as? VIPFlowNavigationController
        else {
            finishedExecuting()
            return
        }
        
        vipFlow.flowDelegate = self
        showedGate = true
        originViewController.presentViewController(vipFlow, animated: animated, completion: nil)
    }
    
    func VIPFlowNaivigationController(navigationController: VIPFlowNavigationController, completedFlowWithSuccess success: Bool) {
        self.allowedAccess = success
        navigationController.dismissViewControllerAnimated(animated) { [weak self] in
            self?.finishedExecuting()
        }
    }
}
