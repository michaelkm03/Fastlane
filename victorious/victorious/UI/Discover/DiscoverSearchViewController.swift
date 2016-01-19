//
//  DiscoverSearchViewController.swift
//  victorious
//
//  Created by Patrick Lynch on 1/6/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

public extension DiscoverSearchViewController {
    
    func setupSearchViewControllers() {
        let userSearchVC: SearchResultsViewController = UserSearchViewController.v_fromStoryboard( "UserSearchViewController",
            identifier: "SearchResultsViewController")
        
        userSearchVC.dependencyManager = self.dependencyManager
        userSearchVC.dataSource = UserSearchDataSource()
        self.userSearchViewController = userSearchVC
        
        self.addChildViewController( userSearchVC )
        self.searchResultsContainerView?.addSubview( userSearchVC.view )
        self.view.v_addFitToParentConstraintsToSubview( userSearchVC.view )
        userSearchVC.didMoveToParentViewController(self)
        userSearchVC.searchResultsDelegate = self
        
        let usersNoContentView: VNoContentView = VNoContentView.v_fromNib()
        usersNoContentView.translatesAutoresizingMaskIntoConstraints = false
        usersNoContentView.icon = UIImage(named: "user-icon")?.imageWithRenderingMode(.AlwaysTemplate)
        usersNoContentView.title = NSLocalizedString("No People Found In Search Title", comment:"")
        usersNoContentView.message = NSLocalizedString("No people found in search", comment:"")
        usersNoContentView.resetInitialAnimationState()
        usersNoContentView.setDependencyManager( self.dependencyManager! )
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
        hashtagSearchVC.searchResultsDelegate = self
        
        let hashtagNoContentView: VNoContentView = VNoContentView.v_fromNib()
        hashtagNoContentView.translatesAutoresizingMaskIntoConstraints = false
        hashtagNoContentView.icon = UIImage(named: "tabIconHashtag")?.imageWithRenderingMode(.AlwaysTemplate)
        hashtagNoContentView.title = NSLocalizedString("No Hashtags Found In Search Title", comment:"")
        hashtagNoContentView.message = NSLocalizedString("No hashtags found in search", comment:"")
        hashtagNoContentView.resetInitialAnimationState()
        hashtagNoContentView.setDependencyManager( self.dependencyManager! )
        hashtagSearchVC.noContentView = hashtagNoContentView
    }
}

extension DiscoverSearchViewController: SearchResultsViewControllerDelegate {
    
    func searchResultsViewControllerDidSelectCancel() { }
    
    func searchResultsViewControllerDidSelectResult(result: AnyObject) {
        
        if let userResult = result as? UserSearchResultObject {
            let operation = FetchUserOperation(fromUser: userResult.sourceResult)
            operation.queue() { op in
                if let user = operation.result,
                    let vc = VUserProfileViewController.userProfileWithUser(user, andDependencyManager: self.dependencyManager) {
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
            
        } else if let hashtagResult = result as? HashtagSearchResultObject {
            let hashtag = hashtagResult.sourceResult.tag
            if let vc = dependencyManager?.hashtagStreamWithHashtag(hashtag) {
                navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
}
