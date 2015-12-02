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
    
    private let originViewController: UIViewController
    private let sequenceID: Int64
    
    init( sequenceID: Int64, originViewController: UIViewController ) {
        self.sequenceID = sequenceID
        self.originViewController = originViewController
        super.init( request: FlagSequenceRequest(sequenceID: sequenceID) )
    }
    
    override func onComplete( response: FlagSequenceRequest.ResultType, completion:()->() ) {
        
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
