//
//  DeviceExperimentsRequest.swift
//  victorious
//
//  Created by Michael Sena on 12/8/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import SwiftyJSON

public struct DeviceExperimentsRequest: RequestType {
    
    public init() {
        // just to be public
    }
    
    public var urlRequest: NSURLRequest {
        return NSURLRequest(URL: NSURL(string: "/api/device/experiments")!)
    }
    
    public func parseResponse(response: NSURLResponse, toRequest request: NSURLRequest, responseData: NSData, responseJSON: JSON) throws -> [DeviceExperiment]{
        guard let experimentsJSON = responseJSON["payload"].array else {
            throw ResponseParsingError()
        }
        
        return experimentsJSON.flatMap { DeviceExperiment(json: $0) }
    }
    
}
