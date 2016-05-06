//
//  ViewedContentFetchOperation.swift
//  victorious
//
//  Created by Vincent Ho on 5/6/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

class ViewedContentFetchOperation: RemoteFetcherOperation, RequestOperation {
    
    internal let request: ViewedContentFetchRequest!
    
    required init(request: ViewedContentFetchRequest) {
        self.request = request
    }
    
    convenience init?(macroURLString: String,
                      currentUserID: String,
                      contentID: String) {
        
        guard let request = ViewedContentFetchRequest(macroURLString: macroURLString,
                                                      currentUserID: currentUserID,
                                                      contentID: contentID) else {
                                                        v_log("Failed to create ViewedContentFetchOperation since request failed to initialize. Using macro URL string -> \(macroURLString)")
                                                        return nil
        }
        
        self.init(request: request)
    }
    
    override func main() {
        operationStartTime = NSDate()
        
        requestExecutor.executeRequest(request, onComplete: onComplete, onError: nil)
    }
    
    func onComplete(result: ViewedContentFetchRequest.ResultType) {
        self.results = [result]
    }
}
