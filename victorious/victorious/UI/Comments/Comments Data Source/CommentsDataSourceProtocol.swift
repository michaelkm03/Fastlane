//
//  CommentsDataSourceProtocol.swift
//  victorious
//
//  Created by Michael Sena on 8/14/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import Foundation

protocol CommentsDataSource {
    
    var numberOfComments: Int { get }
    
    func commentAtIndex(index: Int) -> VComment
    
    func indexOfComment(comment: VComment) -> Int
 
    var delegate: CommentsDataSourceDelegate? { get set }
    
    func loadFirstPage()
    
    func loadNextPage()
    
    func loadPreviousPage()
    
    func loadComments(deepLinkCommentID: NSNumber)

}

protocol CommentsDataSourceDelegate {
    
    func commentsDataSourceDidUpdate(dataSource: CommentsDataSource)
    
    func commentsDataSourceDidUpdate(dataSource: CommentsDataSource, deepLinkinkId: NSNumber)
    
}
