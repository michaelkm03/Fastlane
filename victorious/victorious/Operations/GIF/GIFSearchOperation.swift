//
//  GIFSearchOperation.swift
//  victorious
//
//  Created by Tian Lan on 11/30/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

final class GIFSearchOperation: AsyncOperation<[AnyObject]>, PaginatedRequestOperation {
    // MARK: - Initializing
    
    required init(request: GIFSearchRequest) {
        self.searchOptions = request.searchOptions
        self.request = request
        self.requestOperation = RequestOperation(request: request)
    }
    
    convenience init(searchOptions: GIFSearchOptions) {
        let paginator = StandardPaginator(pageNumber: 1, itemsPerPage: 20)
        self.init(request: GIFSearchRequest(searchOptions: searchOptions, paginator: paginator))
    }
    
    // MARK: - Executing
    
    private let searchOptions: GIFSearchOptions?
    
    var request: GIFSearchRequest
    
    private let requestOperation: RequestOperation<GIFSearchRequest>
    
    var results: [AnyObject]?
    
    var requestExecutor: RequestExecutorType {
        get {
            return requestOperation.requestExecutor
        }
        set {
            requestOperation.requestExecutor = newValue
        }
    }
    
    override var executionQueue: Queue {
        return .background
    }
    
    override func execute(finish: (_ result: OperationResult<[AnyObject]>) -> Void) {
        requestOperation.queue { [weak self] result in
            switch result {
                case .success(let searchResults):
                    let searchResultObjects = searchResults.map { GIFSearchResultObject( $0 ) }
                    self?.results = searchResultObjects
                    finish(result: .success(searchResultObjects))
                
                case .failure(let error):
                    self?.results = []
                    finish(result: .failure(error))
                
                case .cancelled:
                    self?.results = []
                    finish(result: .cancelled)
            }
        }
    }
}
