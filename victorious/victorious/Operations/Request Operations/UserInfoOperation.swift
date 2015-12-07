//
//  UserInfoOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 11/16/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

class UserInfoOperation: RequestOperation {
    
    let request: UserInfoRequest
    
    init( userID: Int64 ) {
        self.request = UserInfoRequest(userID: userID)
    }
    
    override func main() {
        self.executeRequest( request, onComplete: self.onComplete )
    }
    
    private func onComplete( user: UserInfoRequest.ResultType, completion:()->() ) {
        persistentStore.asyncFromBackground() { context in
            let persistentUser: VUser = context.findOrCreateObject( [ "remoteId" : NSNumber( longLong: user.userID) ])
            persistentUser.populate(fromSourceModel: user)
            context.saveChanges()
            completion()
        }
    }
}
