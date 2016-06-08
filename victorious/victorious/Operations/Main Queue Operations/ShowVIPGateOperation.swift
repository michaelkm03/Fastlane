//
//  ShowVIPGateOperation.swift
//  victorious
//
//  Created by Jarod Long on 5/10/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

class ShowVIPGateOperation: MainQueueOperation, VIPGateViewControllerDelegate {
    private let dependencyManager: VDependencyManager
    private let animated: Bool
    private weak var originViewController: UIViewController?
    var showedGate = false
    var allowedAccess = false
    
    required init(originViewController: UIViewController, dependencyManager: VDependencyManager, animated: Bool = true) {
        self.dependencyManager = dependencyManager
        self.originViewController = originViewController
        self.animated = animated
    }
    
    override func start() {
        guard !cancelled else {
            finishedExecuting()
            return
        }
        
        guard let viewController = dependencyManager.templateValueOfType(VIPGateViewController.self, forKey: "vipPaygateScreen") as? VIPGateViewController else {
            finishedExecuting()
            return
        }
        
        viewController.delegate = self
        showedGate = true
        
        if let navigationController = originViewController?.navigationController {
            navigationController.pushViewController(viewController, animated: animated)
        } else {
            originViewController?.presentViewController(viewController, animated: animated, completion: nil)
        }
    }
    
    func vipGateViewController(vipGateViewController: VIPGateViewController, allowedAccess allowed: Bool) {
        self.allowedAccess = allowed
        vipGateViewController.dismissViewControllerAnimated(animated) { [weak self] in
            self?.finishedExecuting()
        }
    }
}
