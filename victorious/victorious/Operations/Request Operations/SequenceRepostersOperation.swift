//
//  SequenceRepostersOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 11/23/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

// TODO: See about a `PageableOperationType` protocol that can abstract some of the nextPage and previousPage stuff for calling code

class SequenceRepostersOperation: RequestOperation<SequenceRepostersRequest> {
    
    private let persistentStore: PersistentStoreType = MainPersistentStore()
    
    private let sequenceID: Int64
    
    init( sequenceID: Int64, request: SequenceRepostersRequest ) {
        self.sequenceID = sequenceID
        super.init(request: request)
    }
    
    init( sequenceID: Int64, pageNumber: Int = 1, itemsPerPage: Int = 15) {
        self.sequenceID = sequenceID
        super.init( request: SequenceRepostersRequest(sequenceID: sequenceID, pageNumber: pageNumber, itemsPerPage: itemsPerPage) )
    }
    
    var nextPageOperation: SequenceRepostersOperation?
    var previousPageOperation: SequenceRepostersOperation?
    
    override func onComplete(response: SequenceRepostersRequest.ResultType, completion:()->() ) {
        let users: [User] = response.results
        
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
        
        if let nextPageRequest = response.nextPage {
            self.nextPageOperation = SequenceRepostersOperation( sequenceID: self.sequenceID, request: nextPageRequest )
        }
        if let previousPageRequest = response.previousPage {
            self.previousPageOperation = SequenceRepostersOperation( sequenceID: self.sequenceID, request: previousPageRequest )
        }
    }
}
