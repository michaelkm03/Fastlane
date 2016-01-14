//
//  PollCreateRequest.swift
//  victorious
//
//  Created by Patrick Lynch on 1/5/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation
import SwiftyJSON

public struct PollAnswer {
    let label: String
    let mediaURL: NSURL
    
    public init(label: String, mediaURL: NSURL) {
        self.label = label
        self.mediaURL = mediaURL
    }
}

public struct PollParameters {
    let name: String
    let question: String
    let description: String
    let answers: [PollAnswer]
    
    public init(let name: String, question: String, description: String, answers: [PollAnswer] ) {
        self.name = name
        self.question = question
        self.description = description
        self.answers = answers
    }
}

public struct PollCreateRequest: RequestType {
    
    let requestBody: RequestBodyWriterOutput
    let requestBodyWriter = PollCreateRequestBodyWriter()
    
    public var urlRequest: NSURLRequest {
        let request = NSMutableURLRequest(URL: NSURL(string: "/api/poll/create")!)
        request.HTTPMethod = "POST"
        request.HTTPBodyStream = NSInputStream(URL: requestBody.fileURL)
        request.addValue( requestBody.contentType, forHTTPHeaderField: "Content-Type" )
        
        return request
    }
    
    public init?( parameters: PollParameters ) {
        do {
            self.requestBody = try requestBodyWriter.write( parameters: parameters )
        } catch {
            return nil
        }
    }
    
    public func parseResponse(response: NSURLResponse, toRequest request: NSURLRequest, responseData: NSData, responseJSON: JSON) throws -> String {
        requestBodyWriter.removeBodyTempFile()
        
        let sequenceID = responseJSON["payload"]["sequence_id"]
        
        guard let pollSequenceRemoteID = sequenceID.string else {
            throw ResponseParsingError()
        }
        return pollSequenceRemoteID
    }
}
