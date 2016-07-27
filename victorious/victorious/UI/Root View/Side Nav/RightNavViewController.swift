//
//  RightNavViewController.swift
//  victorious
//
//  Created by Jarod Long on 4/21/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

// FUTURE: Remove this class

/// A view controller that displays the right navigation area of a `SideNavScaffoldViewController`.
class RightNavViewController: UIViewController, CoachmarkDisplayer, VNavigationDestination {
    // MARK: - Initializing
    
    init(dependencyManager: VDependencyManager) {
        self.dependencyManager = dependencyManager
        
        super.init(nibName: nil, bundle: nil)
        
        navigationItem.leftItemsSupplementBackButton = true
    }
    
    required init(coder: NSCoder) {
        fatalError("NSCoding not supported.")
    }
    
    // MARK: - Dependency manager
    
    let dependencyManager: VDependencyManager!
    
    // MARK: - View controllers
    
    /// The view controller that displays the right nav's content.
    var contentViewController: UIViewController?
    
    // MARK: - View events
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        v_addAccessoryScreensWithDependencyManager(dependencyManager)
        
        if contentViewController == nil {
            let contentViewController = dependencyManager.viewControllerForKey("contentScreen")
            addChildViewController(contentViewController)
            view.addSubview(contentViewController.view)
            view.v_addFitToParentConstraintsToSubview(contentViewController.view)
            contentViewController.didMoveToParentViewController(self)
            self.contentViewController = contentViewController
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        v_addBadgingToAccessoryScreensWithDependencyManager(dependencyManager)
    }
    
    // MARK - CoachmarkDisplayer
    func highlightFrame(forIdentifier forIdentifier: String) -> CGRect? {
        return nil 
    }
}
