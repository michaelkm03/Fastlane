//
//  UserInfoOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 11/16/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

class UserInfoOperation: RequestOperation<UserInfoRequest> {
    
    init( userID: Int64 ) {
        super.init( request: UserInfoRequest(userID: userID) )
    }
    
    override func onResponse( response: UserInfoRequest.ResultType ) {
        let persistentStore = PersistentStore()
        let persistentUser: VUser = persistentStore.backgroundContext.findOrCreateObject( [ "remoteId" : Int(response.userID) ])
        persistentUser.populate(fromSourceModel: response)
        guard persistentStore.backgroundContext.saveChanges() else {
            fatalError( "Failed to create new user, something is wrong with the persistence stack!" )
        }
    }
}
