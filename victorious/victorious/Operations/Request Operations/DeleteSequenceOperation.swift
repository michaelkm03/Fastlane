
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
    
    private let sequenceID: Int64
    
    var request: DeleteSequenceRequest
    
    init( sequenceID: Int64 ) {
        self.request = DeleteSequenceRequest(sequenceID: sequenceID)
        self.sequenceID = sequenceID
    }
    
    override func main() {
        executeRequest( self.request )
    }
    
    func onComplete( stream: DeleteSequenceRequest.ResultType, completion:()->() ) {
        persistentStore.asyncFromBackground() { context in
            guard let sequence: VSequence = context.findObjects([ "remoteId" : String(self.sequenceID) ]).first else {
                completion()
                return
            }
            
            context.destroy( sequence )
            context.saveChanges()
            completion()
        }
    }
}
