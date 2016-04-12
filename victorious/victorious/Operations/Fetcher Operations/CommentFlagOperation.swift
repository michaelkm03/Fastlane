//
//  CommentFlagOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 11/24/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

class CommentFlagOperation: FetcherOperation, RequestOperation {
    
    let request: FlagCommentRequest!
    let commentID: Int
    
    private let flaggedContent = VFlaggedContent()
    
    init( commentID: Int ) {
        self.commentID = commentID
        self.request = FlagCommentRequest(commentID: commentID)
        super.init()
    }
    
    override func main() {
        flaggedContent.addRemoteId( String(self.request.commentID), toFlaggedItemsWithType: .Comment)
        
        // Perform data changes optimistically
        persistentStore.createBackgroundContext().v_performBlockAndWait() { context in
            let uniqueElements = [ "remoteId": self.request.commentID ]
            if let comment: VComment = context.v_findObjects( uniqueElements ).first {
                comment.sequence?.commentCount -= 1
                context.deleteObject( comment )
                context.v_save()
            }
        }
        
        CommentFlagRemoteOperation(commentID: commentID).after( self ).queue()
    }
}
