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
    
    private let searchOptions: GIFSearchOptions
    
    required init( request: GIFSearchRequest ) {
        self.searchOptions = request.searchOptions
        self.request = request
    }
    
    convenience init( searchOptions: String ) {
        let paginator = StandardPaginator(pageNumber: 1, itemsPerPage: 20)
        self.init( request: GIFSearchRequest(searchOptions: GIFSearchOptions.Search(term: searchOptions, url: "junk"), paginator: paginator) )
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
