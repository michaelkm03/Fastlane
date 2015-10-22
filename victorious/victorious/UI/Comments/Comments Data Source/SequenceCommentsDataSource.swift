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
        if let comments = self.sequence.comments?.array as? [VComment],
            var validComments = VObjectManager.sharedManager().commentsAfterStrippingFlaggedItems(comments) as? [VComment] {
            validComments.sortInPlace({ $0.postedAt > $1.postedAt })
            self.sortedInternalComments = validComments
        }
    }
    
    func loadFirstPage() {
        
        VObjectManager.sharedManager().loadCommentsOnSequence(sequence,
            pageType: VPageType.Next,
            successBlock: { (operation : NSOperation?, result : AnyObject?, resultObjects : [AnyObject]) in
                self.sortInternalComments()
                dispatch_async(dispatch_get_main_queue()) {
                    self.delegate?.commentsDataSourceDidUpdate(self)
                }
            },
            failBlock: { (operation: NSOperation?, error: NSError?) in
                dispatch_async(dispatch_get_main_queue()) {
                    self.delegate?.commentsDataSourceDidUpdate(self)
                }
            })
    }
    
    func loadNextPage() {
        VObjectManager.sharedManager().loadCommentsOnSequence(sequence,
            pageType: VPageType.Next,
            successBlock: { (operation : NSOperation?, result : AnyObject?, resultObjects : [AnyObject]) in
                self.sortInternalComments()
                dispatch_async(dispatch_get_main_queue()){
                    self.delegate?.commentsDataSourceDidUpdate(self)
                }
            },
            failBlock: nil)
    }
    
    func loadPreviousPage() {
        VObjectManager.sharedManager().loadCommentsOnSequence(sequence,
            pageType: VPageType.Previous,
            successBlock: { (operation : NSOperation?, result : AnyObject?, resultObjects : [AnyObject]) in
                self.sortInternalComments()
                dispatch_async(dispatch_get_main_queue()){
                    self.delegate?.commentsDataSourceDidUpdate(self)
                }
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
        if let commentIndex = sortedInternalComments.indexOf(comment) {
            return commentIndex
        }
        return 0
    }
    
    weak var delegate : CommentsDataSourceDelegate? {
        didSet {
            if delegate != nil {
                loadFirstPage()
            }
        }
    }
    
    func loadComments(commentID: NSNumber) {
        VObjectManager.sharedManager().findCommentPageOnSequence(sequence, withCommentId: commentID,
            successBlock: { (operation : NSOperation?, result : AnyObject?, resultObjects : [AnyObject]) in
            dispatch_async(dispatch_get_main_queue()){
                self.delegate?.commentsDataSourceDidUpdate(self, deepLinkId: commentID)
            }
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
