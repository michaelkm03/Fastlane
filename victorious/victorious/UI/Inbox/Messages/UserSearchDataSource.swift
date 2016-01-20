//
//  UserSearchDataSource.swift
//  victorious
//
//  Created by Michael Sena on 1/5/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

protocol UserSearchDataSourceDelegate: class {
    
    func dataSourceDidUpdate(dataSource: UserSearchDataSource)
    
}

class UserSearchDataSource: NSObject, UITableViewDataSource {
    
    weak var delegate: UserSearchDataSourceDelegate?
    
    private let paginatedDataSource = PaginatedDataSource()
    
    var visibleItems: NSOrderedSet {
        return paginatedDataSource.visibleItems
    }
    
    var isLoading: Bool {
        return paginatedDataSource.isLoading
    }
    
    private(set) var searchQuery: String?
    
    //MARK: - API
    
    func searchWithNewSearchQuery(searchQuery: String) {
        self.searchQuery = searchQuery
        guard let operation = UserSearchOperation(queryString: searchQuery) else {
            return
        }
        
        paginatedDataSource.loadPage(.First,
            createOperation: {
                return operation
            }, completion: { [weak self](operation, error) in
                if let strongSelf = self,
                    delegate = strongSelf.delegate {
                        delegate.dataSourceDidUpdate(strongSelf)
                }
            }
        )
        paginatedDataSource.clearVisibleItems()
        delegate?.dataSourceDidUpdate(self)
    }
    
    func loadNextPage(completion: (NSError?) -> Void) {
        
        guard let searchQuery = searchQuery,
            let operation = UserSearchOperation(queryString: searchQuery) else {
            completion(nil)
            return
        }
        
        self.paginatedDataSource.loadPage(.Next,
            createOperation: {
                return operation
            },
            completion: { [weak self](operation, error)in
                completion(error)
                if let strongSelf = self {
                    strongSelf.delegate?.dataSourceDidUpdate(strongSelf)
                }
            }
        )
    }
    
    func userForIndexPath(indexPath: NSIndexPath) -> VictoriousIOSSDK.User? {
        guard paginatedDataSource.visibleItems.count > indexPath.row else {
            return nil
        }
        guard let networkUser = paginatedDataSource.visibleItems[indexPath.row] as? UserSearchResultObject else {
            return nil
        }
        return networkUser.sourceResult
    }
    
    func bindCell(cell: UITableViewCell, forIndexPath indexPath: NSIndexPath) {
        if let cell = cell as? UserSearchResultTableViewCell,
            let visibleItem = paginatedDataSource.visibleItems[indexPath.row] as? UserSearchResultObject {
                let userNetworkStruct = visibleItem.sourceResult
                let username = userNetworkStruct.name ?? ""
                let profileURLString = userNetworkStruct.profileImageURL ?? ""
                let profileURL = NSURL(string: profileURLString) ?? NSURL()
                let cellViewData = UserSearchResultTableViewCell.ViewData(username: username, profileURL:profileURL)
                cell.viewData = cellViewData
        }
    }
    
    //MARK: - UITableViewDataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.paginatedDataSource.isLoading ? 2 : 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return self.paginatedDataSource.visibleItems.count ?? 0
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
    
}
