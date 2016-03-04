//
//  GIFSearchOperation.swift
//  victorious
//
//  Created by Tian Lan on 11/30/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

final class GIFSearchOperation: RemoteFetcherOperation, PaginatedRequestOperation {
    
    let request: GIFSearchRequest
    
    private let searchTerm: String?
    
    required init( request: GIFSearchRequest ) {
        self.searchTerm = request.searchTerm
        self.request = request
    }
    
    convenience init( searchTerm: String? ) {
        let paginator = StandardPaginator(pageNumber: 1, itemsPerPage: 20)
        self.init( request: GIFSearchRequest(searchTerm: searchTerm, paginator: paginator) )
    }
    
    override func main() {
        requestExecutor.executeRequest( request, onComplete: self.onComplete, onError: self.onError )
    }
    
    func onError( error: NSError) {
        self.results = []
    }
    
    func onComplete( results: GIFSearchRequest.ResultType) {
        self.results = results.map { GIFSearchResultObject( $0 ) }
    }
}
