//
//  AcknowledgeAlertRequest.swift
//  victorious
//
//  Created by Michael Sena on 11/16/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import SwiftyJSON

public struct AcknowledgeAlertRequest: RequestType {

    public let alertID: Int
    private static let basePath = NSURL(string: "/api/alert/acknowledge")!
    
    public var urlRequest: NSURLRequest {
        let urlRequest = NSMutableURLRequest(URL: AcknowledgeAlertRequest.basePath)
        let params = [ "alert_id" : String(alertID) ]
        urlRequest.vsdk_addURLEncodedFormPost(params)
        return urlRequest
    }
    
    public init(alertID: Int) {
        self.alertID = alertID
    }
    
}
