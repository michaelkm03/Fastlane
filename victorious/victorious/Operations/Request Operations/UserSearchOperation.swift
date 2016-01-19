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
    internal(set) var didClearResults = false
    
    let request: UserSearchRequest
    
    private let searchTerm: String
    
    required init( request: UserSearchRequest ) {
        self.request = request
        self.searchTerm = request.searchTerm
    }
    
    convenience init?( searchTerm: String ) {
        let charSet = NSCharacterSet.vsdk_pathPartCharacterSet()
        guard let escapedSearchTerm = searchTerm.stringByAddingPercentEncodingWithAllowedCharacters(charSet) else {
            /// Call self.init(request:) here to prevent crash when this initializer fails and returns nil
            self.init(request: UserSearchRequest(searchTerm: ""))
            
            return nil
        }
        self.init(request: UserSearchRequest(searchTerm: escapedSearchTerm))
    }
    
    override func main() {
        requestExecutor.executeRequest(self.request, onComplete: self.onComplete, onError: nil)
    }
    
    func onComplete(networkResult: UserSearchRequest.ResultType, completion: () -> () ) {
        
        guard !networkResult.isEmpty else {
            results = []
            completion()
            return
        }
        
        self.results = networkResult.map{ UserSearchResultObject( user: $0) }
        
        // Call the completion block before the Core Data context saves because consumers only care about the networkUsers
        completion()

        // Populate our local users cache based off the new data
        storedBackgroundContext = persistentStore.createBackgroundContext().v_performBlock() { context in
            guard !networkResult.isEmpty else {
                return
            }
            
            for networkUser in networkResult {
                let localUser: VUser = context.v_findOrCreateObject([ "remoteId" : networkUser.userID])
                localUser.populate(fromSourceModel: networkUser)
            }
            context.v_save()
        }
    }
    
    // MARK: - PaginatedOperation
    
    internal(set) var results: [AnyObject]?
    
    func fetchResults() -> [AnyObject] {
        return self.results ?? []
    }
    
    func clearResults() { }
}
