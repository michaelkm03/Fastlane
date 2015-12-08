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
    
    var request: SequenceRepostersRequest
    
    private var sequenceID: Int64
    
    required init( request: SequenceRepostersRequest ) {
        self.sequenceID = request.sequenceID
        self.request = request
    }
    
    convenience init( sequenceID: Int64, pageNumber: Int = 1, itemsPerPage: Int = 15) {
        self.init( request: SequenceRepostersRequest(sequenceID: sequenceID, pageNumber: pageNumber, itemsPerPage: itemsPerPage) )
    }
    
    override func main() {
        executeRequest( request, onComplete: self.onComplete )
    }
    
    private func onComplete( users: SequenceRepostersRequest.ResultType, completion:()->() ) {
        
        persistentStore.asyncFromBackground() { context in
            // Load the persistent models (VUser) from the provided networking models (User)
            var reposters = [VUser]()
            let sortedUsers = users.sort {
                return ($0.name ?? "").localizedCaseInsensitiveCompare($1.name ?? "") == NSComparisonResult.OrderedAscending
            }
            for user in sortedUsers {
                let uniqueElements = [ "remoteId" : NSNumber( longLong: user.userID ) ]
                let reposter: VUser
                if let existingUser: VUser = context.findObjects( uniqueElements, limit: 1 ).first {
                    reposter = existingUser
                } else {
                    reposter = context.createObject()
                    reposter.populate(fromSourceModel: user )
                }
                reposters.append( reposter )
            }
            
            // Add the loaded persistent models to the sequence as `reposters`
            let uniqueElements = [ "remoteId" : String(self.sequenceID) ]
            let sequence: VSequence = context.findOrCreateObject(uniqueElements)
            sequence.addObjects( reposters, to: "reposters" )
            context.saveChanges()
            
            completion()
        }
    }
}
