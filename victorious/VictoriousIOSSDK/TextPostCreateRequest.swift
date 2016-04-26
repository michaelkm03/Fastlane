//
//  TextPostCreateRequest.swift
//  victorious
//
//  Created by Tian Lan on 1/11/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

#if os(iOS)

import UIKit

public struct TextPostParameters {
    public let content: String
    public let backgroundColor: UIColor?
    public let backgroundImageURL: NSURL?
    
    public init(content: String, backgroundImageURL: NSURL?, backgroundColor: UIColor?) {
        self.content = content
        self.backgroundColor = backgroundColor
        self.backgroundImageURL = backgroundImageURL
    }
    
    func isInvalid() -> Bool {
        let noBackground = backgroundColor == nil && backgroundImageURL == nil
        return noBackground
    }
}

public struct TextPostCreateRequest: RequestType {
    
    public let parameters: TextPostParameters
    public let injectedBaseURL: NSURL
    
    public init?(parameters: TextPostParameters, baseURL: NSURL) {
        if parameters.isInvalid() {
            return nil
        }
        self.parameters = parameters
        self.injectedBaseURL = baseURL
    }
    
    public var baseURL: NSURL? {
        return injectedBaseURL
    }
    
    public var urlRequest: NSURLRequest {
        let request = NSMutableURLRequest(URL: NSURL(string: "/api/text/create", relativeToURL: baseURL)!)
        request.HTTPMethod = "POST"
        
        return request
    }
    
    public func parseResponse(response: NSURLResponse, toRequest request: NSURLRequest, responseData: NSData, responseJSON: JSON) throws -> String {        
        let sequenceID = responseJSON["payload"]["sequence_id"]
        
        guard let textPostSequenceID = sequenceID.string else {
            throw ResponseParsingError()
        }
        return textPostSequenceID
    }
}

#endif
