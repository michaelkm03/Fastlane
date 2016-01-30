//
//  DiscoverSearchViewController.swift
//  victorious
//
//  Created by Patrick Lynch on 1/6/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

extension DiscoverSearchViewController {
    
    func setupSearchViewControllers() {
        let userSearchVC: SearchResultsViewController = UserSearchViewController.v_fromStoryboard( "UserSearchViewController",
            identifier: "SearchResultsViewController")
        
        userSearchVC.dependencyManager = self.dependencyManager
        userSearchVC.dataSource = UserSearchDataSource(dependencyManager: dependencyManager)
        self.userSearchViewController = userSearchVC
        
        self.addChildViewController( userSearchVC )
        self.searchResultsContainerView?.addSubview( userSearchVC.view )
        self.view.v_addFitToParentConstraintsToSubview( userSearchVC.view )
        userSearchVC.didMoveToParentViewController(self)
        
        let usersNoContentView: VNoContentView = VNoContentView.v_fromNib()
        usersNoContentView.icon = UIImage(named: "user-icon")?.imageWithRenderingMode(.AlwaysTemplate)
        usersNoContentView.title = NSLocalizedString("No People Found In Search Title", comment:"")
        usersNoContentView.message = NSLocalizedString("No people found in search", comment:"")
        usersNoContentView.resetInitialAnimationState()
        usersNoContentView.setDependencyManager(self.dependencyManager)
        userSearchVC.noContentView = usersNoContentView
        
        let hashtagSearchVC: SearchResultsViewController = UserSearchViewController.v_fromStoryboard( "UserSearchViewController",
            identifier: "SearchResultsViewController")
        
        hashtagSearchVC.dependencyManager = self.dependencyManager
        hashtagSearchVC.dataSource = HashtagSearchDataSource(dependencyManager: self.dependencyManager)
        self.hashtagsSearchViewController = hashtagSearchVC
        
        self.addChildViewController( hashtagSearchVC )
        self.searchResultsContainerView?.addSubview( hashtagSearchVC.view )
        self.view.v_addFitToParentConstraintsToSubview( hashtagSearchVC.view )
        hashtagSearchVC.didMoveToParentViewController(self)
        
        let hashtagNoContentView: VNoContentView = VNoContentView.v_fromNib()
        hashtagNoContentView.icon = UIImage(named: "tabIconHashtag")?.imageWithRenderingMode(.AlwaysTemplate)
        hashtagNoContentView.title = NSLocalizedString("No Hashtags Found In Search Title", comment:"")
        hashtagNoContentView.message = NSLocalizedString("No hashtags found in search", comment:"")
        hashtagNoContentView.resetInitialAnimationState()
        hashtagNoContentView.setDependencyManager(self.dependencyManager)
        hashtagSearchVC.noContentView = hashtagNoContentView
    }
    
    func setFirstResponder() {
        // Unable to immediately make the searchBar first responder without this hack
        dispatch_after(0.01) {
            self.searchController.searchBar.becomeFirstResponder()
        }
    }
}

extension DiscoverSearchViewController: SearchResultsViewControllerDelegate {

    // MARK: - SearchResultsViewControllerDelegate
    // These methods merely forward on to containing view controller that has access to
    // the active navigation controller
    
    var searchController: UISearchController {
        return self.searchResultsDelegate?.searchController ?? UISearchController()
    }
    
    func searchResultsViewControllerDidSelectCancel() {
        self.searchResultsDelegate?.searchResultsViewControllerDidSelectCancel()
    }
    
    func searchResultsViewControllerDidSelectResult(result: AnyObject) {
        self.searchResultsDelegate?.searchResultsViewControllerDidSelectResult(result)
    }
}
