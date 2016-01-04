//
//  VHashtagFollowingTableViewController.swift
//  victorious
//
//  Created by Patrick Lynch on 12/20/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation

public extension VHashtagFollowingTableViewController {
    
    public func loadHashtags( pageType pageType: VPageType, completion:(NSError? -> ())? ) {
        self.paginatedDataSource.delegate = self
        self.paginatedDataSource.loadPage( pageType,
            createOperation: {
                return FollowedHashtagsOperation()
            },
            completion: { (op, error) in
                completion?(error)
            }
        )
    }
}

extension VHashtagFollowingTableViewController: PaginatedDataSourceDelegate {

    func paginatedDataSource(paginatedDataSource: PaginatedDataSource, didUpdateVisibleItemsFrom oldValue: NSOrderedSet, to newValue: NSOrderedSet) {
        self.tableView.v_applyChangeInSection(0, from: oldValue, to: newValue)
    }
}
