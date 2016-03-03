//
//  CommentCreateRemoteOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 12/1/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

/// Sends a recently-created local comment over the network to be saved to the Victorious backend
class CommentCreateRemoteOperation: RemoteFetcherOperation, RequestOperation {
    
    var request: CommentAddRequest!
    
    private let localCommentID: NSManagedObjectID
    
    required init( request: CommentAddRequest, localCommentID: NSManagedObjectID) {
        self.request = request
        self.localCommentID = localCommentID
    }
    
    convenience init?( localCommentID: NSManagedObjectID, creationParameters: Comment.CreationParameters) {
        guard let request = CommentAddRequest(creationParameters: creationParameters) else {
            return nil
        }
        self.init(request: request, localCommentID: localCommentID)
    }
    
    override func main() {
        requestExecutor.executeRequest( request, onComplete: onComplete, onError: nil )
    }
    
    func onComplete( comment: CommentAddRequest.ResultType, completion:()->() ) {
        persistentStore.createBackgroundContext().v_performBlockAndWait() { context in
            
            guard let optimisticObject = context.objectWithID( self.localCommentID ) as? VComment else {
                    completion()
                    return
            }
            
            // Repopulate the comment after created on server to provide remoteId and other properties
            optimisticObject.populate( fromSourceModel: comment )
            context.v_save()
            completion()
        }
    }
}

