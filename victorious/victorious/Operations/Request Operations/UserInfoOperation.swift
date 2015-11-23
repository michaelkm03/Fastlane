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
    
    private let persistentStore: PersistentStoreType = MainPersistentStore()
    
    init( userID: Int64 ) {
        super.init( request: UserInfoRequest(userID: userID) )
    }
    
    override func onError(error: NSError) {
        
    }
    
    override func onComplete( response: UserInfoRequest.ResultType, completion:()->() ) {
        
        persistentStore.asyncFromBackground() { context in
            let persistentUser: VUser = context.findOrCreateObject( [ "remoteId" : Int(response.userID) ])
            persistentUser.populate(fromSourceModel: response)
            context.saveChanges()
            completion()
        }
    }
}
