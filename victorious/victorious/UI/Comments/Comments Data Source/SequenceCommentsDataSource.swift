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
        sortInternalComments()
    }
    
    private var sortedInternalComments = [VComment]()
    
    func sortInternalComments() {
        var sortedComments = self.sequence.comments?.sortedArrayUsingComparator{
            let comment1 = $0 as! VComment
            let comment2 = $1 as! VComment
            let result = comment2.postedAt.compare(comment1.postedAt)
            return result
        }
        sortedInternalComments = sortedComments as! [VComment]
    }
    
    func loadFirstPage() {
        
        VObjectManager.sharedManager().loadCommentsOnSequence(sequence,
            pageType: VPageType.Next,
            successBlock: { (operation : NSOperation?, result : AnyObject?, resultObjects : [AnyObject]) in
                self.sortInternalComments()
                dispatch_async(dispatch_get_main_queue(), { () in
                    delegate?.commentsDataSourceDidUpdate(self)
                })
            },
            failBlock: nil)
    }
    
    func loadNextPage() {
        VObjectManager.sharedManager().loadCommentsOnSequence(sequence,
            pageType: VPageType.Next,
            successBlock: { (operation : NSOperation?, result : AnyObject?, resultObjects : [AnyObject]) in
                self.sortInternalComments()
                dispatch_async(dispatch_get_main_queue(), { () in
                    delegate?.commentsDataSourceDidUpdate(self)
                })
            },
            failBlock: nil)
    }
    
    func loadPreviousPage() {
        VObjectManager.sharedManager().loadCommentsOnSequence(sequence,
            pageType: VPageType.Previous,
            successBlock: { (operation : NSOperation?, result : AnyObject?, resultObjects : [AnyObject]) in
                self.sortInternalComments()
                dispatch_async(dispatch_get_main_queue(), { () in
                    delegate?.commentsDataSourceDidUpdate(self)
                })
            },
            failBlock: nil)
    }
    
    var numberOfComments: Int {
        return self.sortedInternalComments.count
    }
    
    func commentAtIndex(index: Int) -> VComment {
        return self.sortedInternalComments[index]
    }
    
    func indexOfComment(comment: VComment) -> Int {
        return find(sortedInternalComments, comment)!
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
            dispatch_async(dispatch_get_main_queue(), { () in
                delegate?.commentsDataSourceDidUpdate(self, deepLinkId: commentID)
            })
        },
            failBlock: nil)
    }
    
    func removeCommentAtIndex(index: Int) {
        var updatedComments = sortedInternalComments
        updatedComments.removeAtIndex(index)
        sortedInternalComments = updatedComments
        delegate?.commentsDataSourceDidUpdate(self)
    }

}
