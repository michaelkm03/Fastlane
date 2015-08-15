//
//  SequenceCommentsDataSource.swift
//  victorious
//
//  Created by Michael Sena on 8/14/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import Foundation

class SequenceCommentsDataSource : CommentsDataSource {
    
    let sequence : VSequence
    
    
    init(sequence: VSequence) {
        self.sequence = sequence
    }
    
    func loadFirstPage() {
        
        VObjectManager.sharedManager().loadCommentsOnSequence(sequence,
            pageType: VPageType.First,
            successBlock: { (operation : NSOperation?, result : AnyObject?, resultObjects : [AnyObject]) -> Void in
                delegate?.commentsDataSourceDidUpdate(self)
            },
            failBlock: nil)
    }
    
    func loadNextPage() {
        VObjectManager.sharedManager().loadCommentsOnSequence(sequence,
            pageType: VPageType.Next,
            successBlock: { (operation : NSOperation?, result : AnyObject?, resultObjects : [AnyObject]) -> Void in
                delegate?.commentsDataSourceDidUpdate(self)
            },
            failBlock: nil)
    }
    
    func loadPreviousPage() {
        VObjectManager.sharedManager().loadCommentsOnSequence(sequence,
            pageType: VPageType.Previous,
            successBlock: { (operation : NSOperation?, result : AnyObject?, resultObjects : [AnyObject]) -> Void in
                delegate?.commentsDataSourceDidUpdate(self)
            },
            failBlock: nil)
    }
    
    var numberOfComments: Int {
        if let comments = sequence.comments {
            return comments.count
        }
        return 0
    }
    
    func commentAtIndex(index: Int) -> VComment {
        if let comments = sequence.comments {
            return comments.array[index] as! VComment
        }
        return VComment()
    }
    
    var delegate : CommentsDataSourceDelegate? {
        didSet {
            if let delegate = delegate {
                loadFirstPage()
            }
        }
    }
    
    func loadComments(commentID: NSNumber) {
        VObjectManager.sharedManager().findCommentPageOnSequence(sequence, withCommentId: commentID, successBlock: { (operation : NSOperation?, result : AnyObject?, resultObjects : [AnyObject]) -> Void in
            self.delegate?.commentsDataSourceDidUpdate(self, deepLinkinkId: commentID)
        },
            failBlock: nil)
    }

}
