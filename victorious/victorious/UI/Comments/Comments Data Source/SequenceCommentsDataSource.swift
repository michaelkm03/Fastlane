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
            successBlock: { (operation : NSOperation?, result : AnyObject?, resultObjects : [AnyObject]) in
                delegate?.commentsDataSourceDidUpdate(self)
            },
            failBlock: nil)
    }
    
    func loadNextPage() {
        VObjectManager.sharedManager().loadCommentsOnSequence(sequence,
            pageType: VPageType.Next,
            successBlock: { (operation : NSOperation?, result : AnyObject?, resultObjects : [AnyObject]) in
                delegate?.commentsDataSourceDidUpdate(self)
            },
            failBlock: nil)
    }
    
    func loadPreviousPage() {
        VObjectManager.sharedManager().loadCommentsOnSequence(sequence,
            pageType: VPageType.Previous,
            successBlock: { (operation : NSOperation?, result : AnyObject?, resultObjects : [AnyObject]) in
                delegate?.commentsDataSourceDidUpdate(self)
            },
            failBlock: nil)
    }
    
    var numberOfComments: Int {
        return sequence.comments?.count ?? 0
    }
    
    func commentAtIndex(index: Int) -> VComment {
        return sequence.comments?.objectAtIndex(index) as? VComment ?? VComment()
    }
    
    func indexOfComment(comment: VComment) -> Int {
        return sequence.comments?.indexOfObject(comment) ?? 0
    }
    
    var delegate : CommentsDataSourceDelegate? {
        didSet {
            if delegate != nil {
                loadFirstPage()
            }
        }
    }
    
    func loadComments(commentID: NSNumber) {
        VObjectManager.sharedManager().findCommentPageOnSequence(sequence, withCommentId: commentID,
            successBlock: { (operation : NSOperation?, result : AnyObject?, resultObjects : [AnyObject]) in
            self.delegate?.commentsDataSourceDidUpdate(self, deepLinkinkId: commentID)
        },
            failBlock: nil)
    }

}
