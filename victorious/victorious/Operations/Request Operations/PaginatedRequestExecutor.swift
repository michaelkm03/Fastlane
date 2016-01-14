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
            
            // When the request finishes successully:
            onComplete: { (result, completion) in
                
                // `onComplete` populates new data into the persistent store received by the network
                if let onComplete = onComplete {
                    onComplete(result) {
                        self.handleSuccess()
                        completion()
                    }
                } else {
                    self.handleSuccess()
                    completion()
                }
            },
            
            // When the request encounters an error
            onError: { (error, completion) in
                
                // Let the operation have first crack at handling the error in case any local changes need be made
                if let onError = onError {
                    onError(error) {
                        self.handleError(error)
                        completion()
                    }
                } else {
                    self.handleError(error)
                    completion()
                }
            }
        )
    }
    
    private func handleSuccess() {
        // Populate the results with fetched data we send that data back
        self.delegate?.results = self.delegate?.fetchResults()
    }
    
    private func handleError( error: NSError ) {
        
        // If the request failed because there's no network connection, fetch the local results
        if error.code == RequestOperation.errorCodeNoNetworkConnection {
            self.delegate?.results = self.delegate?.fetchResults()
            
        } else {
            // Otherwise, return no results
            self.delegate?.results = []
        }
    }
}
