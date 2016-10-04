//
//  AlertsRequestDecorator.swift
//  victorious
//
//  Created by Josh Hinman on 1/24/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

/// Extends an existing RequestType by adding alert parsing
struct AlertsRequestDecorator<T: RequestType>: RequestType {
    let innerRequest: T
    
    init(request: T) {
        self.innerRequest = request
    }
    
    var urlRequest: URLRequest {
        return innerRequest.urlRequest
    }
    
    func parseResponse(_ response: URLResponse, toRequest request: URLRequest, responseData: Data, responseJSON: JSON) throws -> RequestResultWithAlerts<T.ResultType> {
        let result = try innerRequest.parseResponse(response, toRequest: request, responseData: responseData, responseJSON: responseJSON)
        let alerts = responseJSON["alerts"].arrayValue.flatMap { Alert(json: $0) }
        return RequestResultWithAlerts(result: result, alerts: alerts)
    }
}

struct RequestResultWithAlerts<T> {
    let result: T
    let alerts: [Alert]
}
