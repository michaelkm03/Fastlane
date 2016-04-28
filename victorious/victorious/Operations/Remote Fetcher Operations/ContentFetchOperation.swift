//
//  ContentFetchOperation.swift
//  victorious
//
//  Created by Sebastian Nystorm on 25/4/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

class ContentViewFetchOperation: RemoteFetcherOperation, RequestOperation {
    
    internal let request: ContentViewFetchRequest!
    
    required init(request: ContentViewFetchRequest) {
        self.request = request
    }
    
    convenience init?(macroURLString: String, currentUserID: String, contentID: String) {
        guard let request = ContentViewFetchRequest(macroURLString: macroURLString,
                                                    currentUserID: currentUserID,
                                                    contentID: contentID) else {
                                                        v_log("Failed to create ContentViewFetchOperation since request failed to initialize. Using macro URL string -> \(macroURLString)")
                                                        return nil
        }
        self.init(request: request)
    }
    
    override func main() {
        requestExecutor.executeRequest(request, onComplete: onComplete, onError: nil)
    }
    
    func onComplete(result: ContentViewFetchRequest.ResultType) {
        self.results = [result.content]
    }
}
