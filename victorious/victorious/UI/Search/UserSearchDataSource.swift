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
    
    let dependencyManager: VDependencyManager
    let sourceScreenName: String
    
    weak var tableView: UITableView?
    
    required init(dependencyManager: VDependencyManager, sourceScreenName: String) {
        self.dependencyManager = dependencyManager
        self.sourceScreenName = sourceScreenName
    }
    
    func onFollowingUpdated() {
        guard let tableView = tableView else {
            return
        }
        for indexPath in tableView.indexPathsForVisibleRows ?? [] {
            if let cell = tableView.cellForRowAtIndexPath(indexPath) as? UserSearchResultTableViewCell,
                let user = self.visibleItems[ indexPath.row ] as? UserSearchResultObject {
                    self.updateFollowControlState(cell.followControl, forUserID: user.remoteId.integerValue, animated: true)
            }
        }
    }
    
    // MARK: - API
    
    func search(searchTerm searchTerm: String, pageType: VPageType, completion: ((NSError?) -> ())? = nil ) {
        guard let operation = UserSearchOperation(searchTerm: searchTerm) else {
            completion?(nil)
            return
        }
        
        self.searchTerm = searchTerm
        
        loadPage( pageType,
            createOperation: {
                return operation
            },
            completion: { (results, error, cancelled) in
                completion?( error )
            }
        )
    }
    
    func registerCells( forTableView tableView: UITableView ) {
        let identifier = UserSearchResultTableViewCell.defaultReuseIdentifier
        let nib = UINib(nibName: identifier, bundle: NSBundle(forClass: UserSearchResultTableViewCell.self) )
        tableView.registerNib(nib, forCellReuseIdentifier: identifier)
        
        self.tableView = tableView
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.visibleItems.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let identifier = UserSearchResultTableViewCell.defaultReuseIdentifier
        let cell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) as! UserSearchResultTableViewCell
        let visibleItem = visibleItems[indexPath.row] as! UserSearchResultObject
        let user = VUser()
        
        user.populate(fromSourceModel: visibleItem.sourceResult)
        
        let displayName = user.displayName ?? ""
        let userID = visibleItem.sourceResult.id
        let pictureURL = user.pictureURL(ofMinimumSize: cell.preferredPictureSize) ?? NSURL()
        self.updateFollowControlState(cell.followControl, forUserID: userID, animated: false)
        cell.viewData = UserSearchResultTableViewCell.ViewData(username: displayName, profileURL:pictureURL)
        cell.dependencyManager = dependencyManager
        cell.followControl?.onToggleFollow = { _ in
            // FollowUserOperation/FollowUserToggleOperation not supported in 5.0
        }
        return cell
    }
    
    func updateFollowControlState(followControl: VFollowControl?, forUserID userID: Int, animated: Bool = true) {
        guard let followControl = followControl, currentUser = VCurrentUser.user() else {
            return
        }
        let controlState: VFollowControlState
        if currentUser.isFollowingUserID(userID) {
            controlState = .Followed
        } else {
            controlState = .Unfollowed
        }
        followControl.setControlState(controlState, animated: animated)
    }
}
