//
//  CreateTextPostRequest.swift
//  victorious
//
//  Created by Tian Lan on 1/11/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation
import SwiftyJSON

public struct TextPostParameters {
    let content: String
    let backgroundColor: UIColor?
    let backgroundImageURL: NSURL?
    
    public init(content: String, backgroundImageURL: NSURL?, backgroundColor: UIColor?) {
        self.content = content
        self.backgroundColor = backgroundColor
        self.backgroundImageURL = backgroundImageURL
    }
}

public struct CreateTextPostRequest: RequestType {
    
    private let requestBody: RequestBodyWriterOutput
    private let requestBodyWriter = CreateTextPostRequestBodyWriter()
    
    public init?(parameters: TextPostParameters) {
        do {
            self.requestBody = try requestBodyWriter.write( parameters: parameters )
        } catch {
            return nil
        }
    }
    
    public var urlRequest: NSURLRequest {
        let request = NSMutableURLRequest(URL: NSURL(string: "/api/text/create")!)
        request.HTTPMethod = "POST"
        request.HTTPBodyStream = NSInputStream(URL: requestBody.fileURL)
        request.addValue( requestBody.contentType, forHTTPHeaderField: "Content-Type" )
        
        return request
    }
    
    public func parseResponse(response: NSURLResponse, toRequest request: NSURLRequest, responseData: NSData, responseJSON: JSON) throws -> String {
        // When the response come back, it is safe to remove the temp file created by the request body writer
        requestBodyWriter.removeBodyTempFile()
        
        let sequenceID = responseJSON["payload"]["sequence_id"]
        
        guard let textPostSequenceID = sequenceID.string else {
            throw ResponseParsingError()
        }
        return textPostSequenceID
    }
}
