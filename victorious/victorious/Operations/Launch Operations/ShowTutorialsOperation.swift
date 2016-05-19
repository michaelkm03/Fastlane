//
//  ShowTutorialsOperation.swift
//  victorious
//
//  Created by Tian Lan on 5/18/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

class ShowTutorialsOperation: MainQueueOperation {

    private weak var originViewController: UIViewController?
    private let dependencyManager: VDependencyManager
    private let animated: Bool
    
    init(originViewController: UIViewController, dependencyManager: VDependencyManager, animated: Bool = false) {
        self.originViewController = originViewController
        self.dependencyManager = dependencyManager
        self.animated = animated
    }
    
    override func start() {
        guard !self.cancelled else {
            finishedExecuting()
            return
        }
        
        beganExecuting()
        
        guard let tutorialViewController = dependencyManager.templateValueOfType(TutorialViewController.self, forKey: "tutorial") as? TutorialViewController else {
            finishedExecuting()
            return
        }
        
        tutorialViewController.onContinue = { [weak self] in
            self?.finishedExecuting()
        }
        
        let tutorialNavigationController = UINavigationController(rootViewController: tutorialViewController)
        originViewController?.presentViewController(tutorialNavigationController, animated: animated, completion: nil)
    }
}
