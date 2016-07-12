//
//  UserSearchViewController.swift
//  victorious
//
//  Created by Michael Sena on 12/10/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import UIKit
import VictoriousIOSSDK

class UserSearchViewController: UINavigationController, SearchResultsViewControllerDelegate {
    
    weak var searchResultsDelegate: SearchResultsViewControllerDelegate?
    
    private var dependencyManager: VDependencyManager!
    
    class func newWithDependencyManager(dependencyManager: VDependencyManager) -> UserSearchViewController {
        let viewController: UserSearchViewController = UserSearchViewController.v_initialViewControllerFromStoryboard()
        viewController.dependencyManager = dependencyManager
        if let listViewController = viewController.viewControllers.first as? SearchResultsViewController {
            listViewController.dependencyManager = dependencyManager
        }
        return viewController
    }
 
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let viewController = viewControllers.first,
            let searchResultsViewControler = viewController as? SearchResultsViewController {
                
                searchResultsViewControler.dataSource = UserSearchDataSource(dependencyManager: dependencyManager, sourceScreenName: VFollowSourceScreenMessageableUsers)
                searchResultsViewControler.searchResultsDelegate = self
                
                searchController.searchBar.sizeToFit()
                searchController.hidesNavigationBarDuringPresentation = false
                searchController.dimsBackgroundDuringPresentation = false
                searchController.searchBar.showsCancelButton = true
                let placeholderText = NSLocalizedString("Start a new conversation", comment: "")
                dependencyManager.configureSearchBar(searchController.searchBar, placeholderText: placeholderText)
                
                if #available(iOS 9.1, *) {
                    searchController.obscuresBackgroundDuringPresentation = false
                }
                viewController.definesPresentationContext = true // So the presentation doesn't cover our view
                viewController.navigationItem.titleView = searchController.searchBar
                
                let noContentView: VNoContentView = VNoContentView.v_fromNib()
                noContentView.icon = UIImage(named: "user-icon")
                noContentView.title = NSLocalizedString("NoUserSearchResultsTitle", comment:"")
                noContentView.message = NSLocalizedString("NoUserSearchResultsMessage", comment:"")
                noContentView.resetInitialAnimationState()
                noContentView.setDependencyManager( self.dependencyManager! )
                searchResultsViewControler.noContentView = noContentView
        }
        
        dependencyManager.applyStyleToNavigationBar(navigationBar)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // Unable to immediately make the searchBar first responder without this hack
        dispatch_after(0.01) {
            self.searchController.searchBar.becomeFirstResponder()
        }
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    // MARK: - SearchResultsViewControllerDelegate
    
    @objc let searchController = UISearchController(searchResultsController: nil)
    
    func searchResultsViewControllerDidSelectCancel() {
        searchResultsDelegate?.searchResultsViewControllerDidSelectCancel()
    }
    
    func searchResultsViewControllerDidSelectResult(result: AnyObject) {
        searchResultsDelegate?.searchResultsViewControllerDidSelectResult(result)
    }
}
