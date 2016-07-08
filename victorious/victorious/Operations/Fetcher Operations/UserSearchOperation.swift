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
    
    var remoteId: NSNumber {
        return sourceResult.id
    }
}

final class UserSearchOperation: RemoteFetcherOperation, PaginatedRequestOperation {
    internal(set) var didClearResults = false
    
    let request: UserSearchRequest
    
    private let searchTerm: String
    
    required init( request: UserSearchRequest ) {
        self.request = request
        self.searchTerm = request.searchTerm
    }
    
    convenience init?( searchTerm: String ) {

        let charSet = NSCharacterSet.vsdk_pathPartAllowedCharacterSet
        guard let escapedSearchTerm = searchTerm.stringByAddingPercentEncodingWithAllowedCharacters(charSet) else {
            /// Call self.init(request:) here to prevent crash when this initializer fails and returns nil
            self.init(request: UserSearchRequest(searchTerm: ""))
            return nil
        }
        self.init(request: UserSearchRequest(searchTerm: escapedSearchTerm))
    }
    
    override func main() {
        requestExecutor.executeRequest(self.request, onComplete: onComplete, onError: nil)
    }
    
    func onComplete(networkResult: UserSearchRequest.ResultType) {
        
        guard !networkResult.isEmpty else {
            results = []
            return
        }
        
        self.results = networkResult.map{ UserSearchResultObject( user: $0) }
        
        // Use `v_performBlock` to allow operation execution to end while the following
        // block parses results into the persistent storein the background
        persistentStore.createBackgroundContext().v_performBlock() { context in
            guard !networkResult.isEmpty else {
                return
            }
            
            // Populate our local users cache based off the new data
            for networkUser in networkResult {
                let localUser: VUser = context.v_findOrCreateObject([ "remoteId" : networkUser.id])
                localUser.populate(fromSourceModel: networkUser)
            }
            context.v_save()
        }
    }
}
