//
//  FlagCommentOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 11/24/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

class FlagCommentOperation: RequestOperation {
    
    var request: FlagCommentRequest
    
    private let commentID: Int64
    private let flaggedContent = VFlaggedContent()
    
    init( commentID: Int64 ) {
        self.commentID = commentID
        self.request = FlagCommentRequest(commentID: commentID)
    }
    
    private func onComplete( response: FlagCommentRequest.ResultType, completion:()->() ) {
        flaggedContent.addRemoteId( String(self.commentID), toFlaggedItemsWithType: .Comment)
        
        persistentStore.asyncFromBackground() { context in
            let uniqueElements = [ "remoteId" : NSNumber( longLong: self.commentID) ]
            if let comment: VComment = context.findObjects( uniqueElements ).first {
                context.destroy( comment )
                context.saveChanges()
            }
            completion()
        }
    }
}
