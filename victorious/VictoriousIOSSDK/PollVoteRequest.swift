//
//  PollVoteRequest.swift
//  victorious
//
//  Created by Tian Lan on 11/11/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation

/// The request for creating user's answer to a poll
public struct PollVoteRequest: RequestType {
    public let pollAnswer: PollAnswer
    
    public init(sequenceID: Int64, answerID: Int64) {
        self.pollAnswer = PollAnswer(sequenceID: sequenceID, answerID: answerID)
    }
    
    public var urlRequest: NSURLRequest {
        let pollAnswerInfo = [
            "answer_id": pollAnswer.answerID,
            "sequence_id": pollAnswer.sequenceID
        ]
        
        let request = NSMutableURLRequest(URL: NSURL(string: "/api/pollresult/create")!)
        request.vsdk_addURLEncodedFormPost(pollAnswerInfo)
        
        return request
    }
}
