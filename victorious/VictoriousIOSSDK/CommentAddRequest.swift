//
//  CommentAddRequest.swift
//  victorious
//
//  Created by Cody Kolodziejzyk on 11/12/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import SwiftyJSON

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

/// Adds a comment to a particular sequence
public struct CommentAddRequest: RequestType {
    
    private let requestBody: CommentAddRequestBody.Output
    private let requestBodyWriter = CommentAddRequestBody()
    
    public var urlRequest: NSURLRequest {
        let request = NSMutableURLRequest(URL: NSURL(string: "/api/comment/add")!)
        request.HTTPMethod = "POST"
        request.HTTPBodyStream = NSInputStream(URL: requestBody.fileURL)
        request.addValue( requestBody.contentType, forHTTPHeaderField: "Content-Type" )
        return request.copy() as! NSURLRequest
    }
    
    public init?( parameters: CommentParameters ) {
        do {
            self.requestBody = try requestBodyWriter.write(parameters: parameters)
        } catch {
            return nil
        }
    }
    
    public func parseResponse(response: NSURLResponse, toRequest request: NSURLRequest, responseData: NSData, responseJSON: JSON) throws -> Comment {
        guard let comment = Comment(json: responseJSON["payload"]) else {
            throw ResponseParsingError()
        }
        return comment
    }
}
