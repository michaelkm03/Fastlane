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
 
    /// A delgate to be informed of update events.
    var delegate: CommentsDataSourceDelegate? { get set }
    
    /// Attempts to load the first page of comments.
    func loadFirstPage()
    
    /// Attempts to load subsequent pages after the first page.
    func loadNextPage()
    
    /// Attempts to load the previous page of comments from the current page.
    func loadPreviousPage()
    
    /// Loads comements with a deepLink comment ID.
    func loadComments(deepLinkCommentID: NSNumber)

}

protocol CommentsDataSourceDelegate {
    
    /// Informs the delegate that the data source updated the content of the comments.
    func commentsDataSourceDidUpdate(dataSource: CommentsDataSource)
    
    /// Informs the delegate that the data source updated the content of the comments in relation 
    /// to a loadCommentsWithDeepLinkCommentID request.
    func commentsDataSourceDidUpdate(dataSource: CommentsDataSource, deepLinkinkId: NSNumber)
    
}
