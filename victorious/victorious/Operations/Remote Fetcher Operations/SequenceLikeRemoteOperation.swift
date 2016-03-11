//
//  SequenceLikeRemoteOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 3/3/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

class SequenceLikeRemoteOperation: RemoteFetcherOperation, RequestOperation {
    
    let request: LikeSequenceRequest!
    
    init( sequenceID: String ) {
        self.request = LikeSequenceRequest(sequenceID: sequenceID)
    }
    
    override func main() {
        // Execute the request fire-and-forget style
        requestExecutor.executeRequest( request, onComplete: nil, onError: nil )
    }
}
