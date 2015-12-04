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
    
    required init( request: StreamRequest ) {
        super.init( request: request )
    }
    
    convenience init( apiPath: String, sequenceID: String? = nil, pageNumber: Int = 1, itemsPerPage: Int = 15) {
        self.init( request: StreamRequest(apiPath: apiPath, sequenceID: sequenceID) )
    }
    
    override func onComplete(stream: StreamRequest.ResultType, completion:()->() ) {
        resultCount = stream.items.count
        
        persistentStore.asyncFromBackground() { context in
            let persistentStream: VStream = context.findOrCreateObject( [ "remoteId" : stream.streamID ] )
            let streamItems: [VStreamItem] = stream.items.flatMap {
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
