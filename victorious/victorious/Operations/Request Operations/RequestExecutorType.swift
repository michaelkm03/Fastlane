//
//  RequestExecutorType.swift
//  victorious
//
//  Created by Alex Tamoykin on 12/29/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import VictoriousIOSSDK

protocol RequestExecutorType: class {
    
    var error: NSError? { get }
    
    func executeRequest<T: RequestType>(request: T,
        onComplete: ((T.ResultType, ()->())->())?,
        onError: ((NSError, ()->())->())?)
}

protocol PaginatedRequestExecutorType {
    
    var error: NSError? { get }
    
    var delegate: PaginatedRequestExecutorDelegate? { get }
    
    var startingDisplayOrder: Int { get }
    
    func executeRequest<T: Pageable where T.PaginatorType : NumericPaginator>(request: T,
        onComplete: ((T.ResultType, ()->())->())?,
        onError: ((NSError, ()->())->())?)
}

protocol PaginatedRequestExecutorDelegate: class {
    
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
