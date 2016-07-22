//
//  MediaUploadCreateRequest.swift
//  victorious
//
//  Created by Tian Lan on 1/23/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

public struct MediaUploadCreateRequest: RequestType {
    public init(apiPath: APIPath) {
        baseURL = apiPath.url
    }
    
    public private(set) var baseURL: NSURL?
    
    public var urlRequest: NSURLRequest {
        let request = NSMutableURLRequest(URL: baseURL!)
        request.HTTPMethod = "POST"
        return request
    }
    
    public func parseResponse(response: NSURLResponse, toRequest request: NSURLRequest, responseData: NSData, responseJSON: JSON) throws -> String {
        let sequenceID = responseJSON["payload"]["sequence_id"]
        
        guard let mediaUploadSequenceID = sequenceID.string else {
            throw ResponseParsingError()
        }
        return mediaUploadSequenceID
    }
}
