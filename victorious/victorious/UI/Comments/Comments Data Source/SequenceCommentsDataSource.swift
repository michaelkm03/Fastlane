//
//  SequenceCommentsDataSource.swift
//  victorious
//
//  Created by Michael Sena on 8/14/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import Foundation

class SequenceCommentsDataSource : CommentsDataSource {
    
    let sequence: VSequence
    let flaggedContent = VFlaggedContent()
    
    init(sequence: VSequence) {
        self.sequence = sequence
        sortInternalComments()
    }
    
    private var sortedInternalComments = [VComment]()
    
    func sortInternalComments() {
        self.sortedInternalComments = (sequence.comments.array as? [VComment] ?? []).sort { $0.postedAt > $1.postedAt }
    }
    
    lazy private var successBlock: VSuccessBlock = { [weak self] (_, _, _) in
        guard let strongSelf = self else {
            return
        }
        strongSelf.sortInternalComments()
        strongSelf.delegate?.commentsDataSourceDidUpdate(strongSelf)
    }
    
    lazy private var failBlock: VFailBlock = {[weak self](_, _) in
        guard let strongSelf = self else {
            return
        }
        strongSelf.delegate?.commentsDataSourceDidUpdate(strongSelf)
    }
    
    func loadFirstPage() {
        
        VObjectManager.sharedManager().loadCommentsOnSequence(sequence,
            pageType: VPageType.Next,
            successBlock: successBlock,
            failBlock: failBlock)
    }
    
    func loadNextPage() {
        VObjectManager.sharedManager().loadCommentsOnSequence(sequence,
            pageType: VPageType.Next,
            successBlock: successBlock,
            failBlock: nil)
    }
    
    func loadPreviousPage() {
        VObjectManager.sharedManager().loadCommentsOnSequence(sequence,
            pageType: VPageType.Previous,
            successBlock: successBlock,
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
            successBlock: { [weak self] (_, _, _) in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.delegate?.commentsDataSourceDidUpdate(strongSelf, deepLinkId: commentID)
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
