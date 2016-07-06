//
//  HashtagSearchOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 1/6/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

@objc class HashtagSearchResultObject: NSObject {
    let sourceResult: VictoriousIOSSDK.Hashtag
    let tag: String
    
    init( hashtag: VictoriousIOSSDK.Hashtag ) {
        self.sourceResult = hashtag
        self.tag = hashtag.tag
    }
}

final class HashtagSearchOperation: RemoteFetcherOperation {
    
    let request: HashtagSearchRequest
    
    private let escapedQueryString: String
    
    required init( request: HashtagSearchRequest ) {
        self.request = request
        self.escapedQueryString = request.searchTerm
    }
    
    convenience init?( searchTerm: String, apiPath: APIPath? = nil ) {
        guard let request = HashtagSearchRequest(searchTerm: searchTerm, apiPath: apiPath) else {
            return nil
        }
        self.init(request: request)
    }
    
    override func main() {
        requestExecutor.executeRequest(self.request, onComplete: onComplete, onError: nil)
    }
    
    func onComplete( networkResult: HashtagSearchRequest.ResultType ) {
        self.results = networkResult.map{ HashtagSearchResultObject(hashtag: $0) }
    }
}
