//
//  SequenceRepostersOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 11/23/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

final class SequenceRepostersOperation: RequestOperation, PaginatedOperation {
    
    let request: SequenceRepostersRequest
    
    private var sequenceID: String
    
    private var resultObjectIDs = [NSManagedObjectID]()
    
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
    
    func onComplete( users: SequenceRepostersRequest.ResultType, completion:()->() ) {
        
        storedBackgroundContext = persistentStore.createBackgroundContext().v_performBlock() { context in
            
            // Load the persistent models (VUser) from the provided networking models (User)
            var reposters = [VUser]()
            for user in users {
                let reposter: VUser = context.v_findOrCreateObject( [ "remoteId" : user.userID ] )
                reposter.populate(fromSourceModel: user )
                reposters.append( reposter )
            }
            
            // Add the loaded persistent models to the sequence as `reposters`
            let sequence: VSequence = context.v_findOrCreateObject( [ "remoteId" : self.sequenceID ] )
            sequence.v_addObjects( reposters, to: "reposters" )
            context.v_save()
            
            dispatch_async( dispatch_get_main_queue() ) {
                self.resultObjectIDs = reposters.map { $0.objectID }
                completion()
            }
        }
    }
    
    // MARK: - PaginatedOperation
    
    internal(set) var results: [AnyObject]?
    
    func fetchResults() -> [AnyObject] {
        return self.persistentStore.mainContext.v_performBlockAndWait() { context in
            return self.resultObjectIDs.flatMap { context.objectWithID($0) as? VUser }
        } as [VUser]
    }
    
    func clearResults() { }
}
