//
//  EmptyCommentsDataSource.swift
//  victorious
//
//  Created by Michael Sena on 8/14/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import Foundation

/// An implementation of `CommentsDataSource` that returns 0 for numberOfComments and an empty comment for
class EmtpyCommentsDataSource : CommentsDataSource {
    
    var numberOfComments: Int {
        return 0
    }
    
    func commentAtIndex(index: Int) -> VComment {
        fatalError("An EmtpyCommentsDataSource does not provide valid comments.")
    }

    var delegate: CommentsDataSourceDelegate?

    func loadFirstPage() { }

    func loadNextPage() { }

    func loadPreviousPage() { }
    
    func loadComments(commentID: NSNumber) { }

}