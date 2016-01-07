//
//  VUsersAndTagsSearchViewController.swift
//  victorious
//
//  Created by Patrick Lynch on 1/6/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

public extension VUsersAndTagsSearchViewController {
    
    func search( searchTerm searchTerm: String ) {
        
        if self.segmentedControl?.selectedSegmentIndex == 0 {
            self.userSearchResultsVC.search(searchTerm: searchTerm)
        
        } else if self.segmentedControl?.selectedSegmentIndex == 1 {
            
        }
    }
    
    func setupSearchViewControllers() {
        
        let userSearchVC: SearchResultsViewController = UserSearchViewController.v_fromStoryboard( "UserSearchViewController",
            identifier: "SearchResultsViewController")
        userSearchVC.dependencyManager = self.dependencyManager
        
        self.userSearchResultsVC = userSearchVC
        self.addChildViewController( self.userSearchResultsVC )
        self.searchResultsContainerView?.addSubview( self.userSearchResultsVC.view )
        self.view.v_addFitToParentConstraintsToSubview( self.userSearchResultsVC.view )
        self.userSearchResultsVC.didMoveToParentViewController(self)
        
        let noContentView: VNoContentView = VNoContentView.v_fromNib()
        noContentView.translatesAutoresizingMaskIntoConstraints = false
        noContentView.icon = UIImage(named: "user-icon")?.imageWithRenderingMode(.AlwaysTemplate)
        noContentView.title = NSLocalizedString("No People Found In Search Title", comment:"")
        noContentView.message = NSLocalizedString("No people found in search", comment:"")
        noContentView.resetInitialAnimationState()
        noContentView.setDependencyManager( self.dependencyManager! )
        self.userSearchResultsVC.noContentView = noContentView
    }
}

extension VUsersAndTagsSearchViewController: SearchResultsViewControllerDelegate {
    
    func searchResultsViewControllerDidSelectCancel() { }
    
    func searchResultsViewControllerDidSelectResult(result: UserSearchResultObject) {
    
    }
}
