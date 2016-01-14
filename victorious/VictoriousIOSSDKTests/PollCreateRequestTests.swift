//
//  PollCreateRequestTests.swift
//  victorious
//
//  Created by Tian Lan on 1/13/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import XCTest
import VictoriousIOSSDK
import SwiftyJSON

class PollCreateRequestTests: XCTestCase {
    
    func testRequestWithValidParameters() {
        let mockAnswers = [
            PollAnswer(label: "AAA", mediaURL: NSURL(string: "media_A")!),
            PollAnswer(label: "BBB", mediaURL: NSURL(string: "media_B")!)
        ]
        let mockParameters = PollParameters(name: "mockName", question: "mockQuestion", description: "mockDescription", answers: mockAnswers)
        
        guard let request = PollCreateRequest(parameters: mockParameters) else {
            XCTFail("Request Creation should not fail here")
            return
        }
        
        let urlRequest = request.urlRequest
        
        XCTAssertEqual(urlRequest.URL?.absoluteString, "/api/poll/create")
    }
    
    func testRequestWithInvalidParameters() {
        let mockAnswers = [
            PollAnswer(label: "AAA", mediaURL: NSURL(string: "media_A")!),
            PollAnswer(label: "BBB", mediaURL: NSURL(string: "media_B")!),
            PollAnswer(label: "CCC", mediaURL: NSURL(string: "media_C")!)
        ]
        
        let mockParameters = PollParameters(name: "mockName", question: "mockQuestion", description: "mockDescription", answers: mockAnswers)
        
        XCTAssertNil(PollCreateRequest(parameters: mockParameters))
    }
    
    func testResponse() {
        let mockAnswers = [
            PollAnswer(label: "AAA", mediaURL: NSURL(string: "media_A")!),
            PollAnswer(label: "BBB", mediaURL: NSURL(string: "media_B")!)
        ]
        let mockParameters = PollParameters(name: "mockName", question: "mockQuestion", description: "mockDescription", answers: mockAnswers)
        
        guard let request = PollCreateRequest(parameters: mockParameters) else {
            XCTFail("Request Creation should not fail here")
            return
        }
        
        let mockSequenceID = "mockSequenceID"
        let mockJSON = JSON( [ "payload": ["sequence_id": mockSequenceID] ] )
        
        do {
            let results = try request.parseResponse(NSURLResponse(), toRequest: request.urlRequest, responseData: NSData(), responseJSON: mockJSON)
            
            XCTAssertEqual(results, mockSequenceID)
        } catch {
            XCTFail("Sorry, parseResponse should not throw here")
        }
    }
}
