//
//  CommentParameters.swift
//  victorious
//
//  Created by Patrick Lynch on 12/9/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import UIKit

/// An object used as input to other objects that execute functionalty related
/// to adding comments through the endpoint api/comment/add
public struct CommentParameters {
    
    public struct RealtimeComment {
        public let time: Double
        public let assetID: Int64
        
        public init( time: Double, assetID: Int64 ) {
            self.time = time
            self.assetID = assetID
        }
    }
    
    public let sequenceID: Int64
    public let text: String?
    public let replyToCommentID: Int64?
    public let mediaURL: NSURL?
    public let mediaType: MediaAttachmentType?
    public let realtimeComment: RealtimeComment?
    
    public init( sequenceID: Int64, text: String?, replyToCommentID: Int64?, mediaURL: NSURL?, mediaType: MediaAttachmentType?, realtimeComment: RealtimeComment? ) {
        self.sequenceID = sequenceID
        self.text = text
        self.replyToCommentID = replyToCommentID
        self.mediaURL = mediaURL
        self.mediaType = mediaType
        self.realtimeComment = realtimeComment
    }
}
