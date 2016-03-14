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
    }
    
    func exit() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
