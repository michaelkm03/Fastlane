//
//  WebViewHTMLFetchOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 3/19/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

class WebViewHTMLFetchOperation: FetchWebContentOperation, RequestOperation {
    let request: WebViewHTMLFetchRequest!
    
    init(urlPath: String) {
        request = WebViewHTMLFetchRequest(urlPath: urlPath)
    }
    
    override var publicBaseURL: NSURL {
        if let baseURL = request.publicBaseURL {
            return baseURL
        }
        else {
            fatalError("Base URL not defined")
        }
    }
    
    override func main() {
        requestExecutor.executeRequest(request, onComplete: onComplete, onError: nil)
    }
    
    private func onComplete(htmlString: WebViewHTMLFetchRequest.ResultType) {
        resultHTMLString = htmlString
    }
}
