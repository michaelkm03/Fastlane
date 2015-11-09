//
//  VUser+Serializable.swift
//  victorious
//
//  Created by Patrick Lynch on 11/6/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

extension VUser: DataStoreObject {}

extension VUser: Serializable {
    
    public func serialize( user: User, dataStore: DataStore ) {
        remoteId        = NSNumber(integer: Int(user.userID))
        name            = user.name
    }
}