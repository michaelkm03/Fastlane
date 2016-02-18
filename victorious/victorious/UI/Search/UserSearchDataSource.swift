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
    
    weak var tableView: UITableView?
    
    required init(dependencyManager: VDependencyManager) {
        self.dependencyManager = dependencyManager
        super.init()
        
        if let currentUser = VCurrentUser.user() {
            self.KVOController.observe(currentUser,
                keyPath: "following",
                options: [.New, .Old],
                action: Selector( "onFollowedChanged:" )
            )
        }
    }
    
    func onFollowedChanged( change: [NSObject: AnyObject]! ) {
        guard let objectChanged = ((change?[ NSKeyValueChangeNewKey ] ?? change?[ NSKeyValueChangeOldKey ]) as? NSArray)?.firstObject,
            let user = (objectChanged as? VFollowedUser)?.objectUser else {
                return
        }
        
        let index = visibleItems.indexOfObjectPassingTest() { (obj, idx, stop) in
            return (obj as? UserSearchResultObject)?.sourceResult.userID == user.remoteId.integerValue
        }
        if index != NSNotFound,
            let cell = self.tableView?.cellForRowAtIndexPath(NSIndexPath(forRow: index, inSection: 0)) as? UserSearchResultTableViewCell {
                self.updateFollowControlState(cell.followControl, forUserID: user.remoteId.integerValue, animated: true)
        }
    }
    
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
        
        self.tableView = tableView
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
        let userID = visibleItem.sourceResult.userID
        let profileURLString = userNetworkStruct.profileImageURL ?? ""
        let profileURL = NSURL(string: profileURLString) ?? NSURL()
        self.updateFollowControlState(cell.followControl, forUserID: userID, animated: false)
        cell.viewData = UserSearchResultTableViewCell.ViewData(username: username, profileURL:profileURL)
        cell.dependencyManager = dependencyManager
        cell.followControl?.onToggleFollow = {
            guard let currentUser = VCurrentUser.user() else {
                return
            }
            
            let operation: RequestOperation
            let sourceScreenName = VFollowSourceScreenDiscoverUserSearchResults
            if currentUser.isFollowingUserID(userID) {
                operation = UnfollowUserOperation(userID: userID, sourceScreenName: sourceScreenName)
            } else {
                operation = FollowUsersOperation(userIDs: [userID], sourceScreenName: sourceScreenName)
            }
            operation.queue()
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
