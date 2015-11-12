//
//  AnswerPollActionRequest.swift
//  victorious
//
//  Created by Tian Lan on 11/11/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation

/// The request for creating user's answer to a poll
public struct PollAnsweringActionRequest: RequestType {
    public let answerID: Int64
    public let sequenceID: Int64
    
    public init(answerID: Int64, sequenceID: Int64) {
        self.answerID = answerID
        self.sequenceID = sequenceID
    }
    
    public var urlRequest: NSURLRequest {
        let pollAnswerInfo = [
            "answer_id": answerID,
            "sequence_id": sequenceID
        ]
        
        let request = NSMutableURLRequest(URL: NSURL(string: "/api/pollresult/create")!)
        request.vsdk_addURLEncodedFormPost(pollAnswerInfo)
        
        return request
    }
}
