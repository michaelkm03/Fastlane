//
//  SequenceUnlikeRemoteOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 3/3/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

class SequenceUnlikeRemoteOperation: RemoteFetcherOperation, RequestOperation {
    
    let request: UnlikeSequenceRequest!
    
    init( sequenceID: String ){
        self.request = UnlikeSequenceRequest(sequenceID: sequenceID)
    }
    
    override func main() {
        requestExecutor.executeRequest( request, onComplete: nil, onError: nil )
    }
}
