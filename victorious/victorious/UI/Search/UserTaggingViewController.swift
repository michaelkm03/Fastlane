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
    
    private let dataSource = UserSearchDataSource()
    private var dependencyManager: VDependencyManager!
    
    private(set) var searchTerm: String?
    
    class func newWithDependencyManager(dependencyManager: VDependencyManager) -> UserTaggingViewController {
        let viewController: UserTaggingViewController = UserTaggingViewController.v_initialViewControllerFromStoryboard()
        viewController.dependencyManager = dependencyManager
        return viewController
    }
    
    //MARK: - API
    
    func searchWithTerm(searchTerm:String) {
        let lastSearchterm = self.searchTerm
        self.searchTerm = searchTerm
        // Clear if we are starting from the beginning
        if let lastSearchTerm = lastSearchterm where !searchTerm.containsString(lastSearchTerm) {
            dataSource.unload()
        }
        dataSource.search(searchTerm: searchTerm, pageType: .First)
    }
    
    //MARK: - UIViewController
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == UserTaggingViewController.Constants.embeddedViewControllerSegueIdentifier {
            let searchResultsViewController: SearchResultsViewController = segue.destinationViewController as! SearchResultsViewController
            searchResultsViewController.dependencyManager = dependencyManager
            searchResultsViewController.searchResultsDelegate = self
            searchResultsViewController.dataSource = self.dataSource
        }
    }
    
    //MARK: - SearchResultsViewControllerDelegate
    
    func searchResultsViewControllerDidSelectResult(result: AnyObject) {
        if let result: UserSearchResultObject = result as? UserSearchResultObject {
            let fetchUserOperation = FetchManagedObjectsOnMainContextOperation(withEntityName: VUser.v_entityName(),
                queryDictionary: ["remoteId": result.sourceResult.userID])
            fetchUserOperation.queueOn(NSOperationQueue.mainQueue(), completionBlock: { operation in
                if let user = fetchUserOperation.result?.first as? VUser {
                    self.searchResultsDelegate?.searchResultsViewControllerDidSelectResult(user)
                }
            })
        }
    }
    
    func searchResultsViewControllerDidSelectCancel() {
        self.searchResultsDelegate?.searchResultsViewControllerDidSelectCancel()
    }
    
}
