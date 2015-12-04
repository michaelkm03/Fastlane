//
//  RequestExecutor.swift
//  victorious
//
//  Created by Patrick Lynch on 12/4/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK
import VictoriousCommon

class StreamOperation2: RequestOperation2, StreamItemParser {
    
    var currentRequest: StreamRequest
    
    init( request: StreamRequest ) {
        self.currentRequest = request
    }
    
    convenience init( apiPath: String, sequenceID: String? = nil, pageNumber: Int = 1, itemsPerPage: Int = 15) {
        self.init( request: StreamRequest(apiPath: apiPath, sequenceID: sequenceID)! )
    }
    
    override func start() {
        self.beganExecuting()
        self.executeRequest( self.currentRequest) { (result, error) -> () in
            if let error = error {
                self.error = error
                self.finishedExecuting()
            }
            else if let stream = result {
                self.persistentStore.asyncFromBackground() { context in
                    let persistentStream: VStream = context.findOrCreateObject( [ "remoteId" : stream.streamID ] )
                    let streamItems = self.parseStreamItems( stream.items, context: context)
                    persistentStream.addObjects( streamItems, to: "streamItems" )
                    context.saveChanges()
                    self.finishedExecuting()
                }
            }
        }
    }
}