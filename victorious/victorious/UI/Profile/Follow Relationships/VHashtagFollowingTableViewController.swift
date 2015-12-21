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