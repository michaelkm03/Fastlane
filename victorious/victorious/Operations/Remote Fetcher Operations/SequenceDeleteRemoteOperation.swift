//
//  SequenceDeleteRemoteOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 3/3/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

class SequenceDeleteRemoteOperation: RemoteFetcherOperation, RequestOperation {
    
    let request: DeleteSequenceRequest!
    
    init( sequenceID: String ) {
        self.request = DeleteSequenceRequest(sequenceID: sequenceID)
    }
    
    override func main() {
        requestExecutor.executeRequest( request, onComplete: nil, onError: nil )
    }
}
