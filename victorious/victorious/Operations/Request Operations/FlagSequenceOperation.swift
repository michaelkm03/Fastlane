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
    
    var currentRequest: FlagSequenceRequest
    
    init( sequenceID: Int64 ) {
        self.currentRequest = FlagSequenceRequest(sequenceID: sequenceID)
        self.sequenceID = sequenceID
    }
    
    func onComplete( stream: FlagSequenceRequest.ResultType, completion:()->() ) {
        persistentStore.asyncFromBackground() { context in
            let uniqueElements = [ "remoteId" : NSNumber( longLong: self.sequenceID) ]
            guard let sequence: VSequence = context.findObjects( uniqueElements, limit: 1).first else  {
                fatalError( "Cannot find sequence!" )
            }
            // TODO: Use this property to filter out flagged content
            // TODO: See about using this class for Comments, too
            sequence.isFlagged = true
            context.saveChanges()
            completion()
        }
    }
}
