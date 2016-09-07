//
//  UserInfoOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 11/16/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

class UserInfoOperation: RemoteFetcherOperation {
    
    let request: UserInfoRequest!

    private(set) var user: User?
    
    init?(userID: Int, apiPath: String) {
        guard let request = UserInfoRequest(userID: userID, apiPath: apiPath) else {
            return nil
        }
        self.request = request
    }
    
    override func main() {
        requestExecutor.executeRequest( request, onComplete: onComplete, onError: nil )
    }
    
    private func onComplete( user: User) {
        self.user = user
    }
}
