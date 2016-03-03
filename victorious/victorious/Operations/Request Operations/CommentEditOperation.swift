//
//  CommentEditOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 12/15/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

class CommentEditOperation: FetcherOperation, RequestOperation {
    
    var request: CommentEditRequest!
    
    private let text: String
    private let commentID: Int
    
    private var optimisticObjectID: NSManagedObjectID?
    
    init( commentID: Int, text: String ) {
        self.commentID = commentID
        self.text = text
        self.request = CommentEditRequest(commentID: commentID, text: text)
    }
    
    override func main() {
        
        // Optimistically edit the comment before sending request
        persistentStore.createBackgroundContext().v_performBlockAndWait() { context in
            if let comment: VComment = context.v_findObjects( ["remoteId" : self.commentID] ).first {
                comment.text = self.text
                context.v_save()
                self.optimisticObjectID = comment.objectID
            }
        }
        
        // Then fire and forget
        CommentEditRemoteOperation(commentID: self.commentID, text: self.text).after(self).queue()
    }
}
