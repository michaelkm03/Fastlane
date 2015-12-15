//
//  CommentsDataSourceProtocol.swift
//  victorious
//
//  Created by Michael Sena on 8/14/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import Foundation

/// CommentsDataSource is an abstract interface for interacting with a stream of comments.
protocol CommentsDataSource {
    
    /// The current comment count.
    var numberOfComments: Int { get }
    
    /// A comment for a given index.
    func commentAtIndex(index: Int) -> VComment
    
    /// The index of a particular comment.
    func indexOfComment(comment: VComment) -> Int
    
    /// Loads comements with the specified page
    func loadComments( pageType: VPageType, completion:((NSError?)->())?)
    
    func loadComments( pageType: VPageType )
    
    /// Loads comements with a deepLink comment ID.
    func loadComments(deepLinkCommentID: NSNumber)
}

extension CommentsDataSource {
    func loadComments( pageType: VPageType ) {
        loadComments( pageType, completion: nil )
    }
}