//
//  FlagSequenceOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 11/17/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

class FlagSequenceOperation: RequestOperation {

    private let sequenceID: Int64
    private let flaggedContent = VFlaggedContent()
    
    var currentRequest: FlagSequenceRequest
    
    init( sequenceID: Int64 ) {
        self.currentRequest = FlagSequenceRequest(sequenceID: sequenceID)
        self.sequenceID = sequenceID
    }
    
    func onComplete( stream: FlagSequenceRequest.ResultType, completion:()->() ) {

        persistentStore.asyncFromBackground() { context in
            if let sequence: VSequence = context.findObjects([ "remoteId" : String(self.sequenceID) ]).first {
                context.destroy( sequence )
                context.saveChanges()
            }
            completion()
        }
    }
}
