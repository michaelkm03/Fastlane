//
//  SequenceCommentsDataSource.swift
//  victorious
//
//  Created by Michael Sena on 8/14/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import Foundation

class SequenceCommentsDataSource : PaginatedDataSource {
    
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
        return self.commentsArray[index]
    }
    
    func indexOfComment(comment: VComment) -> Int {
        if let commentIndex = commentsArray.indexOf(comment) {
            return commentIndex
        }
        return 0
    }
    
    func loadComments( pageType: VPageType, completion:((NSError?)->())? = nil ) {
        self.loadPage( pageType,
            createOperation: {
                return SequenceCommentsOperation(sequenceID: self.sequence.remoteId)
            },
            completion: { (operation, error) in
                completion?(error)
            }
        )
    }
    
    func loadComments( atPageForCommentID commentID: NSNumber, completion:((NSError?)->())? = nil ) {
        // TODO:
        /*self.loadPage( pageType,
            createOperation: {
                return CommentFindOperation(sequenceID: self.sequence.remoteId, commentID: commentID.longLongValue )
            },
            completion: { (operation, error) in
                completion?(error)
            }
        )*/
    }
}
