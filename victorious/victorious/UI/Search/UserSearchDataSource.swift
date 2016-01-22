//
//  UserSearchDataSource.swift
//  victorious
//
//  Created by Michael Sena on 1/5/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

final class UserSearchDataSource: PaginatedDataSource, SearchDataSourceType, UITableViewDataSource {
    
    private(set) var searchTerm: String?
    
    //MARK: - API
    
    func search(searchTerm searchTerm: String, pageType: VPageType, completion:((NSError?)->())? = nil ) {
        guard let operation = UserSearchOperation(searchTerm: searchTerm) else {
            completion?(nil)
            return
        }
        
        self.searchTerm = searchTerm
        
        loadPage( pageType,
            createOperation: {
                return operation
            },
            completion: { (operation, error) in
                completion?( error )
            }
        )
    }
    
    func registerCells( forTableView tableView: UITableView ) {
        let identifier = UserSearchResultTableViewCell.suggestedReuseIdentifier()
        let nib = UINib(nibName: identifier, bundle: NSBundle(forClass: UserSearchResultTableViewCell.self) )
        tableView.registerNib(nib, forCellReuseIdentifier: identifier)
    }
    
    //MARK: - UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.visibleItems.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let identifier = UserSearchResultTableViewCell.suggestedReuseIdentifier()
        let cell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) as! UserSearchResultTableViewCell
        let visibleItem = visibleItems[indexPath.row] as! UserSearchResultObject
        let userNetworkStruct = visibleItem.sourceResult
        let username = userNetworkStruct.name ?? ""
        let profileURLString = userNetworkStruct.profileImageURL ?? ""
        let profileURL = NSURL(string: profileURLString) ?? NSURL()
        cell.viewData = UserSearchResultTableViewCell.ViewData(username: username, profileURL:profileURL)
        return cell
    }
}
