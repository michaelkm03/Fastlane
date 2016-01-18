//
//  SendMessageRequest.swift
//  victorious
//
//  Created by Cody Kolodziejzyk on 11/11/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import SwiftyJSON

public struct SendMessageRequest: RequestType {
    
    private let requestBodyWriter = MessageRequestBodyWriter()
    private let requestBody: MessageRequestBodyWriter.RequestBody
    
    public var urlRequest: NSURLRequest {
        let request = NSMutableURLRequest(URL: NSURL(string: "/api/message/send")!)
        request.HTTPMethod = "POST"
        request.HTTPBodyStream = NSInputStream(URL: requestBody.fileURL)
        request.addValue( requestBody.contentType, forHTTPHeaderField: "Content-Type" )
        return request
    }
    
    public init?( creationParameters: Message.CreationParameters ) {
        do {
            self.requestBody = try requestBodyWriter.write(parameters: creationParameters)
        } catch {
            return nil
        }
    }
    
    public func parseResponse(response: NSURLResponse, toRequest request: NSURLRequest, responseData: NSData, responseJSON: JSON) throws -> (conversationID: Int, messageID: Int) {
        let payload = responseJSON["payload"]
        
        let conversationIDJSON = payload["conversation_id"]
        let messageIDJSON = payload["message_id"]
        
        guard let conversationID = Int(conversationIDJSON.stringValue) ?? conversationIDJSON.int,
            let messageID = Int(messageIDJSON.stringValue) ?? messageIDJSON.int else {
                throw ResponseParsingError()
        }
        return (conversationID, messageID)
    }
}
