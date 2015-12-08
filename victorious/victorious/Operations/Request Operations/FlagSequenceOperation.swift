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
    
    let request: FlagSequenceRequest
    
    init( sequenceID: Int64 ) {
        self.request = FlagSequenceRequest(sequenceID: sequenceID)
        self.sequenceID = sequenceID
    }
    
    override func main() {
        executeRequest( self.request )
    }
    
    func onComplete( stream: FlagSequenceRequest.ResultType, completion:()->() ) {
        persistentStore.asyncFromBackground() { context in
            guard let sequence: VSequence = context.findObjects([ "remoteId" : String(self.sequenceID) ]).first else {
                completion()
                return
            }
            
            context.destroy( sequence )
            context.saveChanges()
            
            dispatch_async( dispatch_get_main_queue() ) {
                self.flaggedContent.addRemoteId( sequence.remoteId, toFlaggedItemsWithType: .StreamItem)
                completion()
            }
        }
    }
}


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
