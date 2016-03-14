//
//  SequenceLikeOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 11/17/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

class SequenceLikeOperation: FetcherOperation {
    
    private let sequenceID: String
    
    init( sequenceID: String ){
        self.sequenceID = sequenceID
    }
    
    override func main() {
        // Make data change optimistically before executing the request
        persistentStore.createBackgroundContext().v_performBlockAndWait() { context in
            guard let currentUser = VCurrentUser.user(inManagedObjectContext: context),
                let sequence: VSequence = context.v_findObjects(  [ "remoteId" : self.sequenceID ] ).first else {
                    return
            }
            
            sequence.isLikedByMainUser = true
            sequence.likeCount += 1
            
            let predicate = NSPredicate( format: "sequence.remoteId == %@", argumentArray: [self.sequenceID] )
            let newDisplayOrder = context.v_displayOrderForNewObjectWithEntityName(VSequenceLiker.v_entityName(), predicate: predicate)
            
            let uniqueElements = [ "sequence"  : sequence, "user" : currentUser ]
            let sequenceLiker: VSequenceLiker = context.v_findOrCreateObject(uniqueElements)
            sequenceLiker.sequence = sequence
            sequenceLiker.user = currentUser
            sequenceLiker.displayOrder = newDisplayOrder
            context.v_save()
        }
        
        SequenceLikeRemoteOperation(sequenceID: sequenceID).after(self).queue()
    }
}
