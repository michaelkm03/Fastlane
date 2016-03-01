//
//  PollCreateRequest.swift
//  victorious
//
//  Created by Patrick Lynch on 1/5/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

public struct PollAnswer {
    public let label: String
    public let mediaURL: NSURL
    
    public init(label: String, mediaURL: NSURL) {
        self.label = label
        self.mediaURL = mediaURL
    }
}

public struct PollParameters {
    public let name: String
    public let question: String
    public let description: String
    public let answers: [PollAnswer]
    
    public init(let name: String, question: String, description: String, answers: [PollAnswer] ) {
        self.name = name
        self.question = question
        self.description = description
        self.answers = answers
    }
    
    func isInvalid() -> Bool {
        let invalidAnswersCount = answers.count != 2
        let invalidMediaURL = (answers.first?.mediaURL == nil) || (answers.last?.mediaURL == nil)
        
        return (invalidAnswersCount || invalidMediaURL)
    }
}

public struct PollCreateRequest: RequestType {
    
    public let parameters: PollParameters
    public let baseURL: NSURL
    
    public init?( parameters: PollParameters, baseURL: NSURL ) {
        if parameters.isInvalid() {
            return nil
        }
        self.parameters = parameters
        self.baseURL = baseURL
    }
    
    public var urlRequest: NSURLRequest {
        let request = NSMutableURLRequest(URL: NSURL(string: "/api/poll/create", relativeToURL: baseURL)!)
        request.HTTPMethod = "POST"
        
        return request
    }

    public func parseResponse(response: NSURLResponse, toRequest request: NSURLRequest, responseData: NSData, responseJSON: JSON) throws -> String {
        let sequenceID = responseJSON["payload"]["sequence_id"]
        
        guard let pollSequenceRemoteID = sequenceID.string else {
            throw ResponseParsingError()
        }
        return pollSequenceRemoteID
    }
}
