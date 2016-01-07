//
//  UserSearchOperation.swift
//  victorious
//
//  Created by Michael Sena on 12/1/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

@objc class UserSearchResultObject: NSObject {
    let sourceResult: VictoriousIOSSDK.User
    
    init(user: VictoriousIOSSDK.User) {
        sourceResult = user
    }
}

final class UserSearchOperation: RequestOperation, PaginatedOperation {
    
    private(set) var results: [AnyObject]?
    private(set) var didResetResults = false
    
    let request: UserSearchRequest
    private let escapedQueryString: String
    
    required init( request: UserSearchRequest ) {
        self.request = request
        self.escapedQueryString = request.queryString
    }
    
    convenience init?( queryString: String ) {
        guard let escapedString = queryString.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.vsdk_pathPartCharacterSet()) else {
            return nil
        }
        self.init(request: UserSearchRequest(query: escapedString))
    }
    
    override func main() {
        requestExecutor.executeRequest(self.request, onComplete: self.onComplete, onError: self.onError)
    }
    
    private func onError( error: NSError, completion: ()->() ) {
        completion()
    }
    
    private func onComplete(result: UserSearchRequest.ResultType, completion: () -> () ) {
        
        self.results = result.map{ UserSearchResultObject( user: $0) }
        
        // Call the completion block before the Core Data context saves because consumers only care about the networkUsers
        completion()
        
        // Populate our local users cache based off the new data
        persistentStore.backgroundContext.v_performBlock { context in
            guard !result.isEmpty else {
                return
            }
            
            for networkUser in result {
                let localUser: VUser = context.v_findOrCreateObject([ "remoteId" : NSNumber(integer: networkUser.userID)])
                localUser.populate(fromSourceModel: networkUser)
            }
            context.v_save()
        }
    }
}
