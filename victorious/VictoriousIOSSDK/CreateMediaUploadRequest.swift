//
//  CreateMediaUploadRequest.swift
//  victorious
//
//  Created by Tian Lan on 1/23/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation
import SwiftyJSON

public struct CreateMediaUploadRequest: RequestType {
    
    public let baseURL: NSURL
    
    public init(baseURL: NSURL) {
        self.baseURL = baseURL
    }
    
    public var urlRequest: NSURLRequest {
        let request = NSMutableURLRequest(URL: NSURL(string: "/api/mediaupload/create", relativeToURL: baseURL)!)
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
