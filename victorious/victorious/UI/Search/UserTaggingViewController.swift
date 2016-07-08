//
//  UserTaggingViewController.swift
//  victorious
//
//  Created by Michael Sena on 1/26/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

class UserTaggingViewController: UIViewController, SearchResultsViewControllerDelegate {
    
    private struct Constants {
        static let embeddedViewControllerSegueIdentifier = "embeddedSearchResultsViewController"
    }
    
    weak var searchResultsDelegate: SearchResultsViewControllerDelegate?
    
    private lazy var dataSource: UserSearchDataSource = {
        guard let dependencyManager = self.dependencyManager else {
            fatalError( "UserTaggingViewController is missing a dependency manager." )
        }
        return UserSearchDataSource(dependencyManager: dependencyManager,
            sourceScreenName: VFollowSourceScreenDiscoverUserSearchResults)
    }()
    
    private var dependencyManager: VDependencyManager?
    
    class func newWithDependencyManager(dependencyManager: VDependencyManager) -> UserTaggingViewController {
        let viewController: UserTaggingViewController = UserTaggingViewController.v_initialViewControllerFromStoryboard()
        viewController.dependencyManager = dependencyManager
        return viewController
    }
    
    // MARK: - API
    
    func searchWithTerm(searchTerm: String) {
        dataSource.search(searchTerm: searchTerm, pageType: .First)
    }
    
    // MARK: - UIViewController
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == UserTaggingViewController.Constants.embeddedViewControllerSegueIdentifier {
            let searchResultsViewController: SearchResultsViewController = segue.destinationViewController as! SearchResultsViewController
            searchResultsViewController.dependencyManager = dependencyManager
            searchResultsViewController.searchResultsDelegate = self
            searchResultsViewController.dataSource = self.dataSource
        }
    }
    
    // MARK: - SearchResultsViewControllerDelegate
    
    func searchResultsViewControllerDidSelectResult(result: AnyObject) {
        guard let result: UserSearchResultObject = result as? UserSearchResultObject else {
            return
        }
        
        let fetchUserOperation = FetchFromMainContextOperation(
            entityName: VUser.v_entityName(),
            predicate: NSPredicate(format: "remoteId == %i", result.sourceResult.id)
        )
        fetchUserOperation.queue() { results, error, cancelled in
            if let user = results?.first as? VUser {
                self.searchResultsDelegate?.searchResultsViewControllerDidSelectResult(user)
            }
        }
    }

    func searchResultsViewControllerDidSelectCancel() {
        self.searchResultsDelegate?.searchResultsViewControllerDidSelectCancel()
    }
}
