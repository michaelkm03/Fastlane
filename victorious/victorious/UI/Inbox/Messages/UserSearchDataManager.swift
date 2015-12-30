//
//  UserSearchDataManager.swift
//  victorious
//
//  Created by Michael Sena on 12/2/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

/// A UserSearchDataManager manages pagination and queueing of UserSearchOperations.
/// As responses come in pages are added to the foundUsers array.
/// You should create a new UserSearchFetcher for each userSearchQuery.
@objc(VUserSearchDataManager)
class UserSearchDataManager: NSObject {
    
    /// The searchQuery for this UserSearchFetcher
    let userSearchQuery: String
    /// An escaped string appropriate for including as part of a URL path
    let escapedSearchQuery: String
    
    let paginatedDataSource = PaginatedDataSource()
    
    /// The current operation being executed.
    private var searchLoadOperation: UserSearchOperation?

    /// Creates a new UserSearchFetcher with the provided search query. 
    /// The initializer will attempt to percent encode any restricted characters for formatting in the URL path.
    init?(searchQuery: String) {
        guard let escapedString = searchQuery.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.vsdk_pathPartCharacterSet()) else {
            userSearchQuery = searchQuery
            escapedSearchQuery = ""
            searchLoadOperation = nil
            super.init()
            return nil
        }
        
        userSearchQuery = searchQuery
        escapedSearchQuery = escapedString
        
        super.init()
    }
    
    /// Loads the corresponding page if available. Completion block is called after the SearchOperationFinishes.
    /// **NOTE:** This is at some point after the network request has returned.
    func loadPage( pageType: VPageType, withCompletion completion:(NSError?) -> ()) {
        
        let operation = UserSearchOperation(queryString: escapedSearchQuery)
        self.paginatedDataSource.loadPage( pageType,
            createOperation: {
                return operation
            },
            completion: { (operation, error) in
                if let error = error {
                    completion( error )
                } else {
                    completion( nil )
                }
            }
        )
    }
    
    /// Returns whether or not there is a nother page to load, i.e. we are not already at the end of the stream.
    func canLoadNextPage() -> Bool {
        guard paginatedDataSource.isLoading == false else {
            return false
        }
        return self.paginatedDataSource.canLoadPageType(.Next)
    }
}
