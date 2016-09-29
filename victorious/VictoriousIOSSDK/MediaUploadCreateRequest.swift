//
//  MediaUploadCreateRequest.swift
//  victorious
//
//  Created by Tian Lan on 1/23/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

public struct MediaUploadCreateRequest: RequestType {
    private let url: URL
    
    public init?(apiPath: APIPath) {
        guard let url = apiPath.url else {
            return nil
        }
        
        self.url = url
    }
    
    public var urlRequest: URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        return request
    }
    
    public func parseResponse(response: URLResponse, toRequest request: URLRequest, responseData: Data, responseJSON: JSON) throws -> String {
        let sequenceID = responseJSON["payload"]["sequence_id"]
        
        guard let mediaUploadSequenceID = sequenceID.string else {
            throw ResponseParsingError()
        }
        return mediaUploadSequenceID
    }
}
