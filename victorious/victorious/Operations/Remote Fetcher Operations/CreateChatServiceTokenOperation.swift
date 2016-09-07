//
//  CreateChatServiceTokenOperation.swift
//  victorious
//
//  Created by Sebastian Nystorm on 6/4/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

/// Encapsulates fetching the use once authentication token for a specific user.
class CreateChatServiceTokenOperation: RemoteFetcherOperation {

    let request: CreateChatServiceTokenRequest!

    required init(request: CreateChatServiceTokenRequest) {
        self.request = request
    }
    
    convenience init?(expandableURLString: String, currentUserID: Int) {
        guard let request = CreateChatServiceTokenRequest(expandableURLString: expandableURLString, currentUserID: currentUserID) else {
            assertionFailure("Failed to create CreateChatServiceTokenRequest since request failed to initialize.")
            return nil
        }
        self.init(request: request)
    }

    override func main() {
        requestExecutor.executeRequest(request, onComplete: onComplete, onError: nil)
    }

    func onComplete(result: CreateChatServiceTokenRequest.ResultType ) {
        self.results = [result]
    }
}
