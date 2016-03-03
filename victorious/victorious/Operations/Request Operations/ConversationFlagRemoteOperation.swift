//
//  ConversationFlagRemoteOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 3/3/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

class ConversationFlagRemoteOperation: RemoteFetcherOperation, RequestOperation {
    
    let request: FlagConversationRequest!
    
    init(conversationID: Int, mostRecentMessageID: Int) {
        self.request = FlagConversationRequest(mostRecentMessageID: mostRecentMessageID)
    }
    
    override func main() {
        requestExecutor.executeRequest(request, onComplete: nil, onError: nil)
    }
}
