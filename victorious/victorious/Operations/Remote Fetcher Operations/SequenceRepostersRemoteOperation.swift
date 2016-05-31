//
//  SequenceRepostersRemoteOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 3/3/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

final class SequenceRepostersRemoteOperation: RemoteFetcherOperation, PaginatedRequestOperation, PrefetchedResultsOperation {
    
    let request: SequenceRepostersRequest
    
    private var sequenceID: String
    
    // MARK: - PrefetchedResultsOperation
    
    private(set) var resultObjectIDs: [NSManagedObjectID]?
    
    required init( request: SequenceRepostersRequest ) {
        self.sequenceID = request.sequenceID
        self.request = request
    }
    
    convenience init( sequenceID: String ) {
        self.init( request: SequenceRepostersRequest(sequenceID: sequenceID) )
    }
    
    override func main() {
        requestExecutor.executeRequest( request, onComplete: onComplete, onError: nil )
    }
    
    func onComplete( users: SequenceRepostersRequest.ResultType) {
        
        persistentStore.createBackgroundContext().v_performBlockAndWait() { context in
            
            // Load the persistent models (VUser) from the provided networking models (User)
            var reposters = [VUser]()
            for user in users {
                let reposter: VUser = context.v_findOrCreateObject( [ "remoteId" : user.id ] )
                reposter.populate(fromSourceModel: user )
                reposters.append( reposter )
            }
            
            // Add the loaded persistent models to the sequence as `reposters`
            let sequence: VSequence = context.v_findOrCreateObject( [ "remoteId" : self.sequenceID ] )
            sequence.v_addObjects( reposters, to: "reposters" )
            context.v_save()
            
            self.resultObjectIDs = reposters.map { $0.objectID }
        }
    }
}
