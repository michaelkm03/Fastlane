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
class RightNavViewController: UIViewController, CoachmarkDisplayer {
    
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if contentViewController == nil {
            let contentViewController = dependencyManager.viewController(forKey: "contentScreen")
            addChildViewController(contentViewController!)
            view.addSubview(contentViewController?.view)
            view.v_addFitToParentConstraintsToSubview(contentViewController?.view)
            contentViewController?.didMoveToParentViewController(self)
            self.contentViewController = contentViewController
        }
    }
    
    // MARK: - CoachmarkDisplayer
    
    func highlightFrame(forIdentifier: String) -> CGRect? {
        return nil 
    }
}
