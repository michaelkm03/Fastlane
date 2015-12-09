//
//  DevicePreferencesOperation.swift
//  victorious
//
//  Created by Michael Sena on 12/9/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

class DevicePreferencesOperation: RequestOperation {
    
    var notificationPreferences: NotificationPreference?
    
    private var request: DevicePreferencesRequest
    
    override init() {
        request = DevicePreferencesRequest()
    }
    
    init(newPreferences: [NotificationPreference: Bool]) {
        request = DevicePreferencesRequest(preferences: newPreferences)
    }
    
    override func main() {
        executeRequest( request, onComplete: self.onComplete )
    }
    
    private func onComplete( result: DevicePreferencesRequest.ResultType, completion: () -> () ) {
        notificationPreferences = result
        completion()
    }
}
