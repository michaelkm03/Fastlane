//
//  UserSearchDataManagerTableViewAdapter.swift
//  victorious
//
//  Created by Michael Sena on 12/17/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

class UserSearchDataManagerTableViewAdapter: NSObject, UITableViewDataSource, UITableViewDelegate, VScrollPaginatorDelegate {
    
    private enum UserSearchState {
        case Default
        case LoadingInitial
        case LoadingSubsequent
        case NoResults
        case FoundUsers
    }
    
    var searchQuery: String? {
        didSet {
            guard let searchQuery = searchQuery else {
                return
            }
            
            userSearchDataManager = UserSearchDataManager(searchQuery: searchQuery)
            userSearchDataManager!.loadPage(.First, withCompletion: { [weak self]error in
                guard let strongSelf = self else {
                    return
                }
                if (error != nil) {
                    // Handle Error
                }
                dispatch_async(dispatch_get_main_queue(), {
                    strongSelf.updateCurrentSearchState()
                    strongSelf.tableView.reloadData()
                })
            })
            // Se we see the loading next page indicator
            tableView.reloadData()
            updateCurrentSearchState()
        }
    }
    
    private var userSearchDataManager: UserSearchDataManager?
    private let tableView: UITableView
    private let noResultsView: UIView
    private let dependencyManager: VDependencyManager
    private let userSelectionHandler: (user: User) -> Void
    private var searchState = UserSearchState.Default {
        didSet {
            switch searchState {
            case .Default:
                noResultsView.hidden = true
                tableView.hidden = false
            case .LoadingInitial:
                noResultsView.hidden = true
                tableView.hidden = false
            case .LoadingSubsequent:
                noResultsView.hidden = true
                tableView.hidden = false
            case .NoResults:
                noResultsView.hidden = false
                tableView.hidden = true
            case .FoundUsers:
                noResultsView.hidden = true
                tableView.hidden = false
            }
        }
    }
    private lazy var scrollPaginator: VScrollPaginator = {
        let paginator = VScrollPaginator()
        paginator.delegate = self
        return paginator
    }()
    
    init(tableView: UITableView,
        dependencyManager: VDependencyManager,
        noResultsView: UIView,
        userSelectionHandler: (user: User) -> Void) {
            self.tableView = tableView
            self.dependencyManager = dependencyManager
            self.noResultsView = noResultsView
            self.userSelectionHandler = userSelectionHandler
    }
    
    //MARK: - UITableViewDataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        guard let userSearchDataManager = userSearchDataManager else {
            return 0
        }
        return userSearchDataManager.paginatedDataSource.isLoading ? 2 : 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return userSearchDataManager?.paginatedDataSource.visibleItems.count ?? 0
        } else {
            return 1
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            return tableView.dequeueReusableCellWithIdentifier(UserSearchResultTableViewCell.suggestedReuseIdentifier(), forIndexPath: indexPath)
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier(ActivityIndicatorTableViewCell.suggestedReuseIdentifier(), forIndexPath: indexPath) as! ActivityIndicatorTableViewCell
            cell.resumeAnimation()
            return cell
        }
    }
    
    //MARK: - UITableViewDelegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let resultUserObject = userSearchDataManager?.paginatedDataSource.visibleItems.objectAtIndex(indexPath.row) as? UserSearchResultObject {
            userSelectionHandler(user: resultUserObject.sourceResult)
        }
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if let resultCell = cell as? UserSearchResultTableViewCell,
            let sourceResultObject = userSearchDataManager?.paginatedDataSource.visibleItems.objectAtIndex(indexPath.row) as? UserSearchResultObject {
                resultCell.dependencyManager = dependencyManager
                
                let username = sourceResultObject.sourceResult.name ?? ""
                let profileURLString = sourceResultObject.sourceResult.profileImageURL ?? ""
                let profileURL = NSURL(string: profileURLString) ?? NSURL()
                let viewData = UserSearchResultTableViewCell.ViewData(username: username, profileURL: profileURL)
                resultCell.viewData = viewData
        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        scrollPaginator.scrollViewDidScroll(scrollView)
    }
    
    //MARK: - VScrollPaginatorDelegate
    
    func shouldLoadNextPage() {
        guard let userSearchDataManager = userSearchDataManager else {
            return
        }
//        guard userSearchDataManager.canLoadNextPage() else {
//            return
//        }
        
        userSearchDataManager.loadPage(.Next, withCompletion: { [weak self] error in
            guard let strongSelf = self else {
                return
            }
            dispatch_async(dispatch_get_main_queue(), {
                strongSelf.updateCurrentSearchState()
                strongSelf.tableView.reloadData()
                strongSelf.tableView.flashScrollIndicators()
            })
        })
        // Se we see the loading next page indicator
        self.tableView.reloadData()
        updateCurrentSearchState()
    }
    
    //MARK: - Private Methods
    
    func updateCurrentSearchState() {
        guard let userSearchDataManager = userSearchDataManager else {
            self.searchState = .Default
            return
        }
        
        if userSearchDataManager.paginatedDataSource.isLoading {
            if userSearchDataManager.paginatedDataSource.visibleItems.count == 0 {
                self.searchState = .LoadingInitial
            } else {
                self.searchState = .LoadingSubsequent
            }
        } else {
            if userSearchDataManager.paginatedDataSource.visibleItems.count == 0 {
                self.searchState = .NoResults
            } else {
                self.searchState = .FoundUsers
            }
        }
    }
}
