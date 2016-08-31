//
//  DevicePreferencesOperation.swift
//  victorious
//
//  Created by Michael Sena on 12/9/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

class DevicePreferencesOperation: RemoteFetcherOperation, RequestOperation {
    
    // These settings were created with an appropriate ManagedObjectContext for main queue use
    var mainQueueSettings: VNotificationSettings?
    
    let request: DevicePreferencesRequest!

    override init() {
        request = DevicePreferencesRequest()
        super.init()
    }

    init(newPreferences: [NotificationPreference: Bool]) {
        request = DevicePreferencesRequest(preferences: newPreferences)
        super.init()
    }
    
    override func main() {
        requestExecutor.executeRequest( request, onComplete: onComplete, onError: nil )
    }
    
    private func onComplete( result: DevicePreferencesRequest.ResultType ) {
        // FIXME: Figure out a better way of doing this
        
        // Grab the background current user's notificationSettings, creating if none already exist
        
        mainQueueSettings = VNotificationSettings()
        mainQueueSettings?.populate(fromSourceModel: result)
    }
}
