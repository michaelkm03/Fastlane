//
//  CommentDeleteOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 2/1/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

class CommentDeleteOperation: FetcherOperation {
    
    let commentID: Int
    
    private let flaggedContent = VFlaggedContent()
    
    init(commentID: Int, removalReason: String?) {
        self.commentID = commentID
        super.init()
        
        let remoteOperation = CommentDeleteRemoteOperation(commentID: commentID, removalReason: removalReason)
        remoteOperation.after(self).queue()
    }
    
    override func main() {
        // We're also going to flag it locally so that we can filter it from backend responses
        // while parsing in the future.
        flaggedContent.addRemoteId( String(self.commentID), toFlaggedItemsWithType: .Comment)
        
        // Perform data changes optimistically
        persistentStore.createBackgroundContext().v_performBlockAndWait() { context in
            let uniqueElements = [ "remoteId" : self.commentID ]
            if let comment: VComment = context.v_findObjects( uniqueElements ).first {
                comment.sequence?.commentCount -= 1
                context.deleteObject( comment )
                context.v_save()
            }
        }
    }
}
