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
    private let pageLoader = PageLoader()
    
    var isLoading: Bool {
        return pageLoader.isLoading
    }
    
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
    
    func loadComments( pageType: VPageType, completion:(NSError?->())?) {
        guard let sequenceID = Int64(self.sequence.remoteId) else {
            return
        }
        
        self.pageLoader.loadPage( pageType,
            createOperation: {
                return SequenceCommentsOperation(sequenceID: sequenceID)
            },
            completion: { (operation, error) in
                completion?(error)
            }
        )
    }
    
    func loadComments(commentID: NSNumber) {
        guard let sequenceID = Int64(self.sequence.remoteId) else {
            return
        }
        CommentFindOperation(sequenceID: sequenceID, commentID: commentID.longLongValue ).queue()
    }
}
