//
//  RegisterPushNotificationRequest.swift
//  victorious
//
//  Created by Tian Lan on 1/11/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

public struct RegisterPushNotificationRequest: RequestType {
    
    public let pushNotificationID: String
    
    public init(pushNotificationID: String) {
        self.pushNotificationID = pushNotificationID
    }
    
    public var urlRequest: URLRequest {
        var urlRequest = URLRequest(url: URL(string: "/api/device/register_push_id")!)
        let deviceInfo = ["push_id": pushNotificationID]
        urlRequest.vsdk_addURLEncodedFormPost(deviceInfo)
        
        return urlRequest
    }
}
