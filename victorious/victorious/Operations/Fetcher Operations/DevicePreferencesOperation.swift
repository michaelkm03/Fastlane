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
        
        // Grab the background current user's notificationSettings, creating if none already exist
        persistentStore.createBackgroundContext().v_performBlockAndWait() { context in
            let currentUser = VCurrentUser.user(inManagedObjectContext: context)
            let newSettings: VNotificationSettings = currentUser?.notificationSettings ?? context.v_createObject()
            currentUser?.notificationSettings = newSettings
            newSettings.populate(fromSourceModel: result)
            context.v_save()
        }
        
        // Provide the main queue current user for calling code.
        persistentStore.mainContext.performBlockAndWait() { context in
            // Provide the main queue current user for calling code.
            let mainQueueCurrentUser = VCurrentUser.user
            self.mainQueueSettings = mainQueueCurrentUser?.notificationSettings
        }
    }
}
