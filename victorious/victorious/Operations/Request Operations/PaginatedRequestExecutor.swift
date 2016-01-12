//
//  PaginatedRequestExecutor.swift
//  victorious
//
//  Created by Patrick Lynch on 1/11/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

class PaginatedRequestExecutor: PaginatedRequestExecutorType {
    
    private(set) var error: NSError?
    
    private var requestExecutor: RequestExecutorType
    
    private(set) var startingDisplayOrder: Int = 0
    
    var delegate: PaginatedRequestExecutorDelegate?
    
    init(requestExecutor: RequestExecutorType) {
        self.requestExecutor = requestExecutor
    }
    
    func executeRequest<T: Pageable where T.PaginatorType : NumericPaginator>(request: T, onComplete: ((T.ResultType, ()->())->())?, onError: ((NSError, ()->())->())?) {
        
        self.startingDisplayOrder = (request.paginator.pageNumber - 1) * request.paginator.itemsPerPage
        
        self.requestExecutor.executeRequest( request,
            onComplete: { (result, completion) in
                
                // When refreshing (first page) with a network connection, old local data needs to be cleared out
                if self.hasNetworkConnection && request.paginator.pageNumber == 1 {
                    self.delegate?.clearResults()
                }
                
                // `onComplete` populates new data into the persistent store received by the network
                onComplete?(result) {
                    
                    // Then we send that data back
                    self.delegate?.results = self.delegate?.fetchResults()
                    completion()
                }
            },
            onError: { (error, completion) in
                
                // Let the operation have first crack at handling the error in case any local changes need be made
                onError?(error) {
                    
                    if error.code == RequestOperation.errorCodeNoNetworkConnection {
                        // If the request failed because there's no network connection, fetch the local results
                        self.delegate?.results = self.delegate?.fetchResults()
                        
                    } else {
                        // Otherwise, return no results
                        self.delegate?.results = []
                    }
                    completion()
                }
            }
        )
    }
    
    private var hasNetworkConnection: Bool {
        return VReachability.reachabilityForInternetConnection().currentReachabilityStatus() != .NotReachable
    }
}
