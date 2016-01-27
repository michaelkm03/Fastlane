//
//  HashtagSearchDataSource.swift
//  victorious
//
//  Created by Patrick Lynch on 1/6/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

final class HashtagSearchDataSource: PaginatedDataSource, SearchDataSourceType, UITableViewDataSource {
    
    private(set) var searchTerm: String?
    
    let dependencyManager: VDependencyManager
    
    let separatorStyle: UITableViewCellSeparatorStyle = .None
    
    required init(dependencyManager: VDependencyManager) {
        self.dependencyManager = dependencyManager
    }
    
    func registerCells( forTableView tableView: UITableView ) {
        let identifier = VHashtagCell.suggestedReuseIdentifier()
        let nib = UINib(nibName: identifier, bundle: NSBundle(forClass: VHashtagCell.self) )
        tableView.registerNib(nib, forCellReuseIdentifier: identifier)
    }
    
    //MARK: - API
    
    func search(searchTerm searchTerm: String, pageType: VPageType, completion:((NSError?)->())? = nil ) {
        
        self.searchTerm = searchTerm
        guard let operation = HashtagSearchOperation(searchTerm: searchTerm) else {
            return
        }
        
        loadPage( pageType,
            createOperation: {
                return HashtagSearchOperation(searchTerm: searchTerm)!
            },
            completion: { (operation, error) in
                completion?( error )
            }
        )
    }
    
    //MARK: - UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.visibleItems.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let identifier = VHashtagCell.suggestedReuseIdentifier()
        let searchResultCell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) as! VHashtagCell
        let hashtagResult = visibleItems[indexPath.row] as! HashtagSearchResultObject
        searchResultCell.dependencyManager = self.dependencyManager
        let hashtag = hashtagResult.sourceResult.tag
        searchResultCell.hashtagText = hashtag
        self.updateFollowControlState(searchResultCell.followHashtagControl, forHashtag: hashtag)
        searchResultCell.onToggleFollowHashtag = { [weak self, weak searchResultCell] in
            guard let currentUser = VCurrentUser.user() else {
                return
            }
            
            let operation: RequestOperation
            if currentUser.isCurrentUserFollowingHashtagString(hashtag) {
                operation = UnfollowHashtagOperation( hashtag: hashtag )
            } else {
                operation = FollowHashtagOperation(hashtag: hashtag)
            }
            operation.queue() { error in
                self?.updateFollowControlState(searchResultCell?.followHashtagControl, forHashtag: hashtag)
            }
        }
        return searchResultCell
    }
    
    func updateFollowControlState(followControl: VFollowControl?, forHashtag hashtag: String) {
        guard let followControl = followControl, currentUser = VCurrentUser.user() else {
            return
        }
        let controlState: VFollowControlState
        if currentUser.isCurrentUserFollowingHashtagString(hashtag) == true {
            controlState = .Followed
        } else {
            controlState = .Unfollowed
        }
        followControl.setControlState(controlState, animated: true)
    }
}
