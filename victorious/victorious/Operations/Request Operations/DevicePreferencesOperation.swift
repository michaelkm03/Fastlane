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
    
    // These settings were created with an appropriate ManagedObjectContext for main queue use
    var mainQueueSettings: VNotificationSettings?
    
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
        persistentStore.asyncFromBackground { context in
            
            // Grab the background current user's notificationSettings, creating if none already exist
            let currentUser = VUser.currentUser()
            let newSettings: VNotificationSettings = currentUser?.notificationSettings ?? context.createObject()
            currentUser?.notificationSettings = newSettings
            newSettings.populate(fromSourceModel: result)
            context.saveChanges()
            
            self.persistentStore.sync({ context in
                // Provide the main queue current user for calling code.
                let mainQueueCurrentUser = VUser.currentUser()
                self.mainQueueSettings = mainQueueCurrentUser?.notificationSettings
                completion()
            })
        }
        
    }
}
