//
//  SequenceUnlikeOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 11/17/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

class SequenceUnlikeOperation: FetcherOperation {
    
    private let sequenceID: String
    
    init( sequenceID: String ){
        self.sequenceID = sequenceID
    }
    
    override func main() {
        persistentStore.createBackgroundContext().v_performBlockAndWait() { context in
            guard let currentUser = VCurrentUser.user(inManagedObjectContext: context),
                let sequence: VSequence = context.v_findObjects( [ "remoteId" : self.sequenceID ] ).first else {
                    return
            }
            
            sequence.isLikedByMainUser = false
            sequence.likeCount -= 1
            
            let uniqueElements = [ "sequence": sequence, "user": currentUser ]
            context.v_deleteObjectsWithEntityName(VSequenceLiker.v_entityName(), queryDictionary: uniqueElements)
            
            context.v_save()
        }
        
        SequenceUnlikeRemoteOperation(sequenceID: sequenceID).after(self).queue()
    }
}
