//
//  ShowVIPFlowOperation.swift
//  victorious
//
//  Created by Jarod Long on 5/10/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

class ShowVIPFlowOperation: MainQueueOperation {
    private let dependencyManager: VDependencyManager
    private let animated: Bool
    private let completion: VIPFlowCompletion?
    private weak var originViewController: UIViewController?
    private(set) var showedGate = false
    
    required init(originViewController: UIViewController, dependencyManager: VDependencyManager, animated: Bool = true, completion: VIPFlowCompletion? = nil) {
        self.dependencyManager = dependencyManager
        self.originViewController = originViewController
        self.animated = animated
        self.completion = completion
    }
    
    override func start() {
        defer {
            finishedExecuting()
        }
        
        guard
            !cancelled,
            let originViewController = originViewController,
            let vipFlow = dependencyManager.templateValueOfType(VIPFlowNavigationController.self, forKey: "vipPaygateScreen") as? VIPFlowNavigationController
        else {
                return
        }
        
        vipFlow.completionBlock = completion
        showedGate = true
        originViewController.presentViewController(vipFlow, animated: animated, completion: nil)
    }
}
