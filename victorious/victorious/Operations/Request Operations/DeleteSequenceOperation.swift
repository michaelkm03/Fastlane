
//
//  DeleteSequenceOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 12/15/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

class DeleteSequenceOperation: RequestOperation {
    
    private let sequenceID: String
    
    var request: DeleteSequenceRequest
    
    init( sequenceID: String ) {
        self.request = DeleteSequenceRequest(sequenceID: sequenceID)
        self.sequenceID = sequenceID
    }
    
    override func main() {
        requestExecutor.executeRequest( request, onComplete: nil, onError: nil )
    }
    
    func onComplete( stream: DeleteSequenceRequest.ResultType, completion:()->() ) {
        persistentStore.backgroundContext.v_performBlock() { context in
            guard let sequence: VSequence = context.v_findObjects([ "remoteId" : self.sequenceID ]).first else {
                completion()
                return
            }
            
            context.deleteObject( sequence )
            context.v_save()
            completion()
        }
    }
}
