//
//  UserSearchDataSource.swift
//  victorious
//
//  Created by Michael Sena on 1/5/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

final class UserSearchDataSource: PaginatedDataSource, UITableViewDataSource {
    
    enum Section: Int {
        case Results
        case ActivityIndicator
        
        static let Count: Int = 2
    }
    
    private(set) var searchTerm: String?
    private(set) var error: NSError?
    
    override init() {
        super.init()
        
        // Search style: clears results when user pressed "Search" button
        clearsVisibleItemsBeforeLoadingFirstPage = true
    }
    
    //MARK: - API
    
    func search(searchTerm searchTerm: String, pageType: VPageType, completion:((NSError?)->())? = nil ) {
        
        self.searchTerm = searchTerm
        guard let operation = UserSearchOperation(queryString: searchTerm) else {
            return
        }
        
        self.error = nil
        
        loadPage( pageType,
            createOperation: {
                return operation
            },
            completion: { (operation, error) in
                self.error = error
                completion?( error )
            }
        )
    }
    
    //MARK: - UITableViewDataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.isLoading ? Section.Count : 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch Section(rawValue: section)! {
            
        case .Results:
            return self.visibleItems.count ?? 0
            
        case .ActivityIndicator:
            return 1
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        switch Section(rawValue: indexPath.section)! {
            
        case .Results:
            let cell = tableView.dequeueReusableCellWithIdentifier(UserSearchResultTableViewCell.suggestedReuseIdentifier(), forIndexPath: indexPath)
            if let searchResultCell = cell as? UserSearchResultTableViewCell,
                let visibleItem = visibleItems[indexPath.row] as? UserSearchResultObject {
                    let userNetworkStruct = visibleItem.sourceResult
                    let username = userNetworkStruct.name ?? ""
                    let profileURLString = userNetworkStruct.profileImageURL ?? ""
                    let profileURL = NSURL(string: profileURLString) ?? NSURL()
                    searchResultCell.viewData = UserSearchResultTableViewCell.ViewData(username: username, profileURL:profileURL)
                    return searchResultCell
            }
            
        case .ActivityIndicator:
            let cell = tableView.dequeueReusableCellWithIdentifier(ActivityIndicatorTableViewCell.suggestedReuseIdentifier(), forIndexPath: indexPath)
            if let activityIndicatorCell = cell as? ActivityIndicatorTableViewCell {
                activityIndicatorCell.resumeAnimation()
                return activityIndicatorCell
            }
        }
        
        fatalError( "Unable to dequeue cell" )
    }
}
