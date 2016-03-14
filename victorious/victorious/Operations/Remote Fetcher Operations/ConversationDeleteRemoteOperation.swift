//
//  ConversationDeleteRemoteOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 3/3/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

class ConversationDeleteRemoteOperation: RemoteFetcherOperation, RequestOperation {
    
    let request: ConversationDeleteRequest!
    
    init(conversationID: Int) {
        self.request = ConversationDeleteRequest(conversationID: conversationID)
    }
    
    override func main() {
        requestExecutor.executeRequest(request, onComplete: nil, onError: nil)
    }
}
