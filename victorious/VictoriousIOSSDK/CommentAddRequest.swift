//
//  CommentAddRequest.swift
//  victorious
//
//  Created by Cody Kolodziejzyk on 11/12/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation

public struct CommentAddRequest: RequestType {
    
    private let requestBodyWriter: CommentRequestBodyWriter
    private let requestBody: CommentRequestBodyWriter.Output
    
    public var urlRequest: NSURLRequest {
        let request = NSMutableURLRequest(URL: NSURL(string: "/api/comment/add")!)
        request.HTTPMethod = "POST"
        request.HTTPBodyStream = NSInputStream(URL: requestBody.fileURL)
        request.addValue( requestBody.contentType, forHTTPHeaderField: "Content-Type" )
        return request
    }
    
    public init?( creationParameters: Comment.CreationParameters ) {
        do {
            requestBodyWriter = CommentRequestBodyWriter(parameters: creationParameters)
            requestBody = try requestBodyWriter.write()
        } catch {
            return nil
        }
    }
    
    public func parseResponse(response: NSURLResponse, toRequest request: NSURLRequest, responseData: NSData, responseJSON: JSON) throws -> Comment {
        requestBodyWriter.removeBodyTempFile()
        
        guard let comment = Comment(json: responseJSON["payload"]) else {
            throw ResponseParsingError()
        }
        return comment
    }
}
