//
//  PaginatedOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 12/4/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

/// Defines an object that can return copies of itself configured for loading next
/// and previous pages of a Pageable request
protocol PaginatedOperation {

    /// The type of Pageable request used by this operation
    typealias PaginatedRequestType: Pageable
    
    /// The current request used for this operation, required in order to get the next/prev requests
    /// from which to maket the next/prev operations.
    var request: PaginatedRequestType { get }
    
    /// Required initializer that takes a value typed to PaginatedRequestType
    init( request: PaginatedRequestType )
    
    /// Returns a copy of this operation configured for loading next page worth of data
    func next() -> Self?
    
    /// Returns a copy of this operation configured for loading previous page worth of data
    func prev() -> Self?

    /// For the particular paginator involved, returns the starting display order for the current page
    /// with the intention that concrete implementations will use this to create a persistent display order
    /// based on the order in which results are received from the network.
    var startingDisplayOrder: Int { get }
    
    /// A place to store the results so that they are available to calling code that is
    /// consuming this delegate (most likely an NSOperation).  This is why the protocol
    /// is required to be implemented by a class.
    var results: [AnyObject]? { set get }
    
    /// Once a network request's response has been parsed and dumped in the persistent store,
    /// this method re-retrives from the main context any of the loaded results that should
    /// be sent back the view controller ready for display on the main thread
    func fetchResults() -> [AnyObject]
    
    /// In some situations is it necessary to clear existing data in the persistent store
    /// to make room for some updated data from the network that supercedes it.  The nature
    /// of this supercession is critial in that if operations were not to clear results
    /// when asked, the ordering and accuracy of results may be unexpected.
    func clearResults()
}

extension PaginatedOperation {

    func prev() -> Self? {
        if let request = PaginatedRequestType(previousFromSourceRequest: self.request) {
            return self.dynamicType.init(request: request)
        }
        return nil
    }
}

extension PaginatedOperation where PaginatedRequestType : ResultBasedPageable {
    
    func next() -> Self? {
        guard let results = self.results else {
            fatalError( "The `resultCount` property has not been set on the receiver (\(self.dynamicType)).  This is required in order to determine if there is a next page available.  I would suggest setting it in the completion closure provided to `RequestOperation`s `requestExecutor.executeRequest(_:onComplete:onError:)` method." )
        }
        if let request = PaginatedRequestType(nextRequestFromRequest: self.request, resultCount: results.count) {
            return self.dynamicType.init(request: request)
        }
        return nil
    }
}

extension PaginatedOperation where PaginatedRequestType.PaginatorType : NumericPaginator {

    var startingDisplayOrder: Int {
        return (request.paginator.pageNumber - 1) * request.paginator.itemsPerPage
    }
}
