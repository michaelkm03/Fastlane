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
    
    init(sequence: VSequence) {
        self.sequence = sequence
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
    
    func loadComments( atPageForCommentID commentID: NSNumber, completion:((Int?, NSError?)->())?) {
        let operation = CommentFindOperation(sequenceID: self.sequence.remoteId, commentID: commentID.longLongValue )
        operation.queue() { error in
            if error == nil, let pageNumber = operation.pageNumber {
                completion?(pageNumber, nil)
            } else {
                completion?(nil, error)
            }
        }
    }
}
