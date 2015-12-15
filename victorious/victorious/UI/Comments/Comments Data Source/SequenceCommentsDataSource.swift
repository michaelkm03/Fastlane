//
//  SequenceCommentsDataSource.swift
//  victorious
//
//  Created by Michael Sena on 8/14/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import Foundation

class SequenceCommentsDataSource : CommentsDataSource {
    
    private let sequence: VSequence
    private let flaggedContent = VFlaggedContent()
    private(set) var isLoadingComments: Bool = false
    private var loadCommentsOperation: SequenceCommentsOperation?
    
    var commentsArray: [VComment] {
        return self.sequence.comments.array as? [VComment] ?? []
    }
    
    init(sequence: VSequence) {
        self.sequence = sequence
    }
    
    var numberOfComments: Int {
        return self.commentsArray.count
    }
    
    func commentAtIndex(index: Int) -> VComment {
        return (self.sequence.comments.array as? [VComment] ?? [])[index]
    }
    
    func indexOfComment(comment: VComment) -> Int {
        if let commentIndex = commentsArray.indexOf(comment) {
            return commentIndex
        }
        return 0
    }
    
    func loadComments( pageType: VPageType ) {
        guard let sequenceID = Int64(self.sequence.remoteId) where !isLoadingComments else {
            return
        }
        
        let operation: SequenceCommentsOperation?
        switch pageType {
        case .First:
            operation =  SequenceCommentsOperation(sequenceID: sequenceID)
        case .Next:
            operation = loadCommentsOperation?.next()
        case .Previous:
            operation = loadCommentsOperation?.prev()
        }
        
        if let currentOperation = operation {
            loadCommentsOperation = currentOperation
            isLoadingComments = true
            currentOperation.queue() { error in
                self.isLoadingComments = false
            }
        }
    }
    
    func loadComments(commentID: NSNumber) {
        guard let sequenceID = Int64(self.sequence.remoteId) else {
            return
        }
        CommentFindOperation(sequenceID: sequenceID, commentID: commentID.longLongValue ).queue()
    }
}
