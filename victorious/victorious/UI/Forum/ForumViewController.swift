//
//  ForumViewController.swift
//  victorious
//
//  Created by Patrick Lynch on 3/9/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

class ForumViewController: UIViewController {
    
    private var dependencyManager: VDependencyManager!
    
    private var stageViewController: StageViewController?
    
    //MARK: - Initialization
    
    class func newWithDependencyManager(dependencyManager: VDependencyManager) -> ForumViewController {
        let viewController = ForumViewController()
        viewController.dependencyManager = dependencyManager
        return viewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = dependencyManager.colorForKey(VDependencyManagerAccentColorKey)
        view.addGestureRecognizer( UITapGestureRecognizer(target: self, action: "exit") )
        
        // TODO: add the correct way...
        addStageViewController()
    }
    
    func exit() {
        removeStageViewController()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - StageViewController
    
    func addStageViewController() {
        let stageVC = StageViewController.new(dependencyManager: dependencyManager)
        self.addChildViewController(stageVC)
        view.addSubview(stageVC.view)
        view.v_addFitToParentConstraintsToSubview(stageVC.view)
        stageVC.didMoveToParentViewController(self)
        stageViewController = stageVC
    }
    
    func removeStageViewController() {
        if let stageViewController = stageViewController {
            stageViewController.willMoveToParentViewController(nil)
            stageViewController.view.removeFromSuperview()
            stageViewController.removeFromParentViewController()
        }
    }
}
