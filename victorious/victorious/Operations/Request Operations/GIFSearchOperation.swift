//
//  GIFSearchOperation.swift
//  victorious
//
//  Created by Tian Lan on 11/30/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

final class GIFSearchOperation: RequestOperation, PaginatedOperation {
    
    let request: GIFSearchRequest
    private(set) var didResetResults: Bool = false

    private(set) var results: [AnyObject]?
    
    private let searchTerm: String
    
    required init( request: GIFSearchRequest ) {
        self.searchTerm = request.searchTerm
        self.request = request
    }
    
    convenience init( searchTerm: String) {
        self.init( request: GIFSearchRequest(searchTerm: searchTerm) )
    }
    
    override func main() {
        requestExecutor.executeRequest( request, onComplete: self.onComplete, onError: self.onError )
    }
    
    func onError( error: NSError, completion:()->() ) {
        self.results = []
        completion()
    }
    
    func onComplete( results: GIFSearchRequest.ResultType, completion:()->() ) {
        self.results = results.map { GIFSearchResultObject( $0 ) }
        completion()
    }
}
