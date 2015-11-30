//
//  GIFSearchRequestOperation.swift
//  victorious
//
//  Created by Tian Lan on 11/30/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

class GIFSearchRequestOperation: RequestOperation<GIFSearchRequest> {
    private(set) var searchResults: [GIFSearchResult] = []
    init(searchText: String) {
        super.init(request: GIFSearchRequest(searchTerm: searchText))
    }
    
    override func onComplete(result: GIFSearchRequest.ResultType, completion: () -> ()) {
        searchResults = result.results.flatMap() {
            
        }
        completion()
    }
}
