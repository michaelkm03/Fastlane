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
    private(set) var error: NSError?
    
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
        searchResultCell.onToggleFollowHashtag = { [weak searchResultCell] in
            ToggleFollowHashtagOperation(hashtag: hashtag).queue() { error in
                searchResultCell?.followHashtagControl?.setControlState(.Followed, animated: true)
            }
        }
        return searchResultCell
    }
}
