//
//  VUser+Serializable.swift
//  victorious
//
//  Created by Patrick Lynch on 11/6/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

extension VUser: DataStoreObject {
    // Will need to implement `entityName` when +RestKit categories are removed
}

extension VUser: Serializable {
    
    func serialize( user: User, dataStore: DataStore ) {
        remoteId        = NSNumber(integer: Int(user.userID))
        name            = user.name
    }
}