//
//  AcknowledgeAlertRequest.swift
//  victorious
//
//  Created by Michael Sena on 11/16/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation

/// Marks an alert as seen by the user, which will remove it from any further response payloads.
public struct AcknowledgeAlertRequest: RequestType {

    public let alertID: String

    public var urlRequest: URLRequest {
        var urlRequest = URLRequest(url: URL(string: "/api/alert/acknowledge")!)
        let params = ["alert_id": alertID]
        urlRequest.vsdk_addURLEncodedFormPost(params)
        return urlRequest
    }

    public init(alertID: String) {
        self.alertID = alertID
    }
}
