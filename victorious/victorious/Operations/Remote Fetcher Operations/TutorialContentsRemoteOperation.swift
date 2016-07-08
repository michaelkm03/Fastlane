//
//  TutorialContentsRemoteOperation.swift
//  victorious
//
//  Created by Tian Lan on 5/6/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

/// Executes a `TutorialContentsRequest` to fetch the tutorial contents from remote endpoint.
/// Populates `self.results` with the contents fetched from remote server
final class TutorialContentsRemoteOperation: RemoteFetcherOperation {
    
    let request: TutorialContentsRequest
    
    required init(request: TutorialContentsRequest) {
        self.request = request
    }
    
    convenience init(urlString: String) {
        let request = TutorialContentsRequest(urlString: urlString)
        self.init(request: request)
    }
    
    override func main() {
        requestExecutor.executeRequest(request, onComplete: onComplete, onError: nil)
    }
    
    private func onComplete(contents: [Content]) {
        self.results = contents
    }
}
