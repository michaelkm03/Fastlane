//
//  DeviceExperimentsRequest.swift
//  victorious
//
//  Created by Michael Sena on 12/8/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation

/// A RequestType for getting the experiments for the current device.
/// - returns: Returns the available experiments as well as the default experimentIDs from parseResponse().
public struct DeviceExperimentsRequest: RequestType {
    
    public init() {
        // just to be public
    }
    
    public var urlRequest: NSURLRequest {
        return NSURLRequest(url: NSURL(string: "/api/device/experiments")! as URL)
    }
    
    public func parseResponse(response: URLResponse, toRequest request: NSURLRequest, responseData: NSData, responseJSON: JSON) throws -> (experiments: [DeviceExperiment], defaultExperimentIDs: Set<Int>) {
        guard let experimentsJSON = responseJSON["payload"].array,
            let defaultExperimentsJSON = responseJSON["experiment_ids"].array else {
                throw ResponseParsingError()
        }
        
        let deviceExperiments = experimentsJSON.flatMap { DeviceExperiment(json: $0) }
        let defaultExperiments = defaultExperimentsJSON.flatMap{ Int($0.stringValue) }
        return (deviceExperiments, Set(defaultExperiments))
    }
}
