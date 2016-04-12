//
//  SequenceRepostOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 11/17/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

class SequenceRepostOperation: FetcherOperation {
    
    private let sequenceID: String
    
    init( sequenceID: String ) {
        self.sequenceID = sequenceID
    }
    
    override func main() {
        
        // Peform optimistic changes before the request is executed
        let didSucceed: Bool = persistentStore.createBackgroundContext().v_performBlockAndWait() { context in
            guard let user = VCurrentUser.user(inManagedObjectContext: context) else {
                return false
            }
            let sequence: VSequence = context.v_findOrCreateObject( [ "remoteId" : self.sequenceID ] )
            guard let node = sequence.firstNode(), let nodeID = node.remoteId?.integerValue else {
                return false
            }
            sequence.hasReposted = true
            sequence.repostCount += 1
            user.v_addObject(sequence, to: "repostedSequences")
            
            context.v_save()
            
            SequenceRepostRemoteOperation(nodeID: nodeID).after(self).queue()
            return true
        }
        
        guard didSucceed else {
            return
        }
    }
}
