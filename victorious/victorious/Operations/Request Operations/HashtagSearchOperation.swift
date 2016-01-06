//
//  HashtagSearchOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 1/6/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

final class HashtagSearchOperation: RequestOperation, PaginatedOperation {
    
    let request: HashtagSearchRequest
    private(set) var didResetResults: Bool = false
    
    private(set) var results: [AnyObject]?
    
    private let searchTerm: String
    
    required init( request: HashtagSearchRequest ) {
        self.searchTerm = request.searchTerm
        self.request = request
    }
    
    convenience init( searchTerm: String) {
        self.init( request: HashtagSearchRequest(searchTerm: searchTerm) )
    }
    
    override func main() {
        requestExecutor.executeRequest( request, onComplete: self.onComplete, onError: self.onError )
    }
    
    func onError( error: NSError, completion:()->() ) {
        self.results = []
        completion()
    }
    
    func onComplete( results: [Hashtag], completion:()->() ) {
        self.results = results.map { HashtagSearchResultObject( $0 ) }
        completion()
    }
}
