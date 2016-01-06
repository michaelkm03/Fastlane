//
//  DeviceExperimentsRequest.swift
//  victorious
//
//  Created by Michael Sena on 12/8/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import SwiftyJSON

/// A RequestType for getting the experiments for the current device.
/// - returns: Returns the available experiments as well as the default experimentIDs from parseResponse().
public struct DeviceExperimentsRequest: RequestType {
    
    public init() {
        // just to be public
    }
    
    public var urlRequest: NSURLRequest {
        return NSURLRequest(URL: NSURL(string: "/api/device/experiments")!)
    }
    
    public func parseResponse(response: NSURLResponse, toRequest request: NSURLRequest, responseData: NSData, responseJSON: JSON) throws -> (experiments: [DeviceExperiment], defaultExperimentIDs: [Int]) {
        guard let experimentsJSON = responseJSON["payload"].array,
            let defaultExperimentsJSON = responseJSON["experiment_ids"].array else {
                throw ResponseParsingError()
        }
        
        let deviceExperiments = experimentsJSON.flatMap { DeviceExperiment(json: $0) }
        let defaultExperiments = defaultExperimentsJSON.flatMap{ Int($0.stringValue) }
        return (deviceExperiments,defaultExperiments)
    }
}
