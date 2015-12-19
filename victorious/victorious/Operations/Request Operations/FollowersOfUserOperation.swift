//
//  FollowersListOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 12/19/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

final class FollowersOfUserOperation: RequestOperation, PaginatedOperation {
    
    let request: FollowersListRequest
    var resultCount: Int?
    
    private var userID: Int64
    
    private let usersParser = UsersParser()
    
    private(set) var loadedUsers = [VUser]()
    
    required init( request: FollowersListRequest ) {
        self.userID = request.userID
        self.request = request
    }
    
    convenience init( userID: Int64 ) {
        self.init( request: FollowersListRequest(userID: userID) )
    }
    
    override func main() {
        executeRequest( request, onComplete: self.onComplete, onError: self.onError )
    }
    
    private func onError( error: NSError, completion:(()->()) ) {
        self.resultCount = 0
        completion()
    }
    
    private func onComplete( users: FollowersListRequest.ResultType, completion:()->() ) {
        self.resultCount = users.count
        
        self.usersParser.parse( users, inStore: self.persistentStore ) { results in
            self.loadedUsers = results
        }
    }
}
