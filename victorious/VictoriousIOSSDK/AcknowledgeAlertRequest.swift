//
//  AcknowledgeAlertRequest.swift
//  victorious
//
//  Created by Michael Sena on 11/16/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation

public struct AcknowledgeAlertRequest: RequestType {

    public let alertID: Int
    
    public var urlRequest: NSURLRequest {
        let urlRequest = NSMutableURLRequest(URL: NSURL(string: "/api/alert/acknowledge")!)
        let params = [ "alert_id" : String(alertID) ]
        urlRequest.vsdk_addURLEncodedFormPost(params)
        return urlRequest
    }
    
    public init(alertID: Int) {
        self.alertID = alertID
    }
}
