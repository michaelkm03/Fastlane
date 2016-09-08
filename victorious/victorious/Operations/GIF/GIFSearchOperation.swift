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
    
    let request: GIFSearchRequest
    
    private let searchTerm: String?
    
    var results: [AnyObject]?
    
    required init(request: GIFSearchRequest) {
        self.searchTerm = request.searchTerm
        self.request = request
    }
    
    convenience init(searchTerm: String?) {
        let paginator = StandardPaginator(pageNumber: 1, itemsPerPage: 20)
        self.init(request: GIFSearchRequest(searchTerm: searchTerm, paginator: paginator))
    }
    
    override var executionQueue: Queue {
        return .background
    }
    
    override func execute(finish: (result: OperationResult<[AnyObject]>) -> Void) {
        RequestOperation(request: request).queue { [weak self] result in
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
