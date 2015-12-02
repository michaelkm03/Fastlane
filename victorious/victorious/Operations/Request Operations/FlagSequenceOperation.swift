//
//  FlagSequenceOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 11/17/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

class FlagSequenceOperation: RequestOperation<FlagSequenceRequest> {
    
    private let persistentStore: PersistentStoreType = MainPersistentStore()
    private let sequenceID: Int64
    private let flaggedContent = VFlaggedContent()
    
    init( sequenceID: Int64 ) {
        self.sequenceID = sequenceID
        super.init( request: FlagSequenceRequest(sequenceID: sequenceID) )
    }
    
    override func onComplete(result:FlagSequenceRequest.ResultType, completion: () -> ()) {
        flaggedContent.addRemoteId( String(self.sequenceID), toFlaggedItemsWithType: .StreamItem)
        
        persistentStore.asyncFromBackground() { context in
            if let sequence: VSequence = context.findObjects([ "remoteId" : String(self.sequenceID) ]).first {
                context.destroy( sequence )
                //context.saveChanges()
            }
            completion()
        }
    }
}
