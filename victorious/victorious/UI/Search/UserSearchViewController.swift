//
//  UserSearchViewController.swift
//  victorious
//
//  Created by Michael Sena on 12/10/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import UIKit
import VictoriousIOSSDK

protocol UserSearchViewControllerDelegate: class {
    
    func userSearchViewControllerDidSelectCancel(userSearchViewController: UserSearchViewController)
    
    func userSearchViewController(userSearchViewController: UserSearchViewController, didSelectUser user: User)
}

class UserSearchViewController: UINavigationController, UserListViewControllerDelegate {
    
    weak var userSearchViewControllerDelegate: UserSearchViewControllerDelegate?
    
    private var dependencyManager: VDependencyManager!
    
    class func newWithDependencyManager(dependencyManager: VDependencyManager) -> UserSearchViewController {
        let viewController: UserSearchViewController = UserSearchViewController.v_initialViewControllerFromStoryboard()
        viewController.dependencyManager = dependencyManager
        if let listViewController = viewController.viewControllers.first as? UserListViewController {
            listViewController.dependencyManager = dependencyManager
        }
        return viewController
    }
 
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let listViewController = viewControllers.first as! UserListViewController
        listViewController.delegate = self
        
        dependencyManager.applyStyleToNavigationBar(navigationBar)
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    //MARK: - UserListViewControllerDelegate
    
    func userListViewControllerDidSelectCancel() {
        userSearchViewControllerDelegate?.userSearchViewControllerDidSelectCancel(self)
    }
    
    func userListViewControllerDidSelectUserID(listViewController: UserListViewController, user: User) {
        userSearchViewControllerDelegate?.userSearchViewController(self, didSelectUser: user)
    }
}
