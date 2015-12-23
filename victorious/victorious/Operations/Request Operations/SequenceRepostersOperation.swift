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
    var resultCount: Int?
    
    private var sequenceID: Int64
    
    required init( request: SequenceRepostersRequest ) {
        self.sequenceID = request.sequenceID
        self.request = request
    }
    
    convenience init( sequenceID: Int64 ) {
        self.init( request: SequenceRepostersRequest(sequenceID: sequenceID) )
    }
    
    override func main() {
        executeRequest( request, onComplete: self.onComplete, onError: self.onError )
    }
    
    private func onError( error: NSError, completion:(()->()) ) {
        self.resultCount = 0
        completion()
    }
    
    private func onComplete( users: SequenceRepostersRequest.ResultType, completion:()->() ) {
        
        self.resultCount = users.count
        
        persistentStore.backgroundContext.v_performBlock() { context in
            // Load the persistent models (VUser) from the provided networking models (User)
            var reposters = [VUser]()
            let sortedUsers = users.sort {
                return ($0.name ?? "").localizedCaseInsensitiveCompare($1.name ?? "") == .OrderedAscending
            }
            for user in sortedUsers {
                let uniqueElements = [ "remoteId" : NSNumber( longLong: user.userID ) ]
                let reposter: VUser
                if let existingUser: VUser = context.v_findObjects( uniqueElements, limit: 1 ).first {
                    reposter = existingUser
                } else {
                    reposter = context.v_createObject()
                    reposter.populate(fromSourceModel: user )
                }
                reposters.append( reposter )
            }
            
            // Add the loaded persistent models to the sequence as `reposters`
            let uniqueElements = [ "remoteId" : String(self.sequenceID) ]
            let sequence: VSequence = context.v_findOrCreateObject(uniqueElements)
            sequence.v_addObjects( reposters, to: "reposters" )
            context.v_save()
            
            completion()
        }
    }
}
