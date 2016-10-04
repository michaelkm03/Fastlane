//
//  StickerSearchOperation.swift
//  victorious
//
//  Created by Sharif Ahmed on 9/21/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

final class StickerSearchOperation: AsyncOperation<[AnyObject]>, PaginatedRequestOperation {
    
    // MARK: - Initializing
    
    required init(request: StickerSearchRequest) {
        self.searchOptions = request.searchOptions
        self.request = request
        self.requestOperation = RequestOperation(request: request)
    }
    
    convenience init(searchOptions: AssetSearchOptions) {
        let paginator = StandardPaginator(pageNumber: 1, itemsPerPage: 20)
        self.init(request: StickerSearchRequest(searchOptions: searchOptions, paginator: paginator))
    }
    
    // MARK: - Executing
    
    private let searchOptions: AssetSearchOptions?
    
    var request: StickerSearchRequest
    
    private let requestOperation: RequestOperation<StickerSearchRequest>
    
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
        return .main
    }
    
    override func execute(finish: (result: OperationResult<[AnyObject]>) -> Void) {
        requestOperation.queue { [weak self] result in
            switch result {
            case .success(let searchResults):
                let searchResultObjects = searchResults.map { StickerSearchResultObject($0) }
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
