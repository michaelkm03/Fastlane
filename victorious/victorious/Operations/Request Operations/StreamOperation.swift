//
//  StreamOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 11/16/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

class StreamOperation: RequestOperation<StreamRequest> {
    
    private let persistentStore: PersistentStoreType = MainPersistentStore()
    
    private let apiPath: String
    
    init( apiPath: String, sequenceID: String? = nil, pageNumber: Int = 1, itemsPerPage: Int = 15) {
        self.apiPath = apiPath
        super.init( request: StreamRequest(apiPath: apiPath, sequenceID: sequenceID) )
    }
    
    override func onComplete(response: StreamRequest.ResultType, completion:()->() ) {
        resultCount = response.count
        persistentStore.asyncFromBackground() { context in
            let persistentStream: VStream = context.findOrCreateObject( [ "apiPath" : self.apiPath ] )
            let streamItems: [VStreamItem] = response.flatMap {
                if let sequence = $0 as? Sequence {
                    let persistentSequence = context.findOrCreateObject([ "remoteId" : String(sequence.sequenceID) ]) as VSequence
                    persistentSequence.populate( fromSourceModel: sequence )
                    return persistentSequence
                }
                else if let stream = $0 as? Stream {
                    let persistentStream = context.findOrCreateObject([ "remoteId" : stream.streamID ]) as VStream
                    persistentStream.populate( fromSourceModel: stream )
                    return persistentStream
                }
                return nil
            }
            persistentStream.addObjects( streamItems, to: "streamItems" )
            context.saveChanges()
            completion()
        }
    }
}
