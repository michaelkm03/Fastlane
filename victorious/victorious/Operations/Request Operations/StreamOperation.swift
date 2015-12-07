//
//  StreamOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 12/4/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

final class StreamOperation: RequestOperation, StreamItemParser, PageableOperationType {
    
    var currentRequest: StreamRequest
    
    private let apiPath: String
    
    required init( request: StreamRequest ) {
        self.apiPath = request.apiPath
        self.currentRequest = request
    }
    
    convenience init( apiPath: String, sequenceID: String? = nil, pageNumber: Int = 1, itemsPerPage: Int = 15) {
        self.init( request: StreamRequest(apiPath: apiPath, sequenceID: sequenceID)! )
    }
    
    override func main() {
        executeRequest( currentRequest, onComplete: self.onComplete )
    }
    
    private func onComplete( stream: StreamRequest.ResultType, completion:()->() ) {
        self.resultCount = stream.items.count //< Pagination depends on the result count being set
        
       persistentStore.asyncFromBackground() { context in
            let persistentStream: VStream = context.findOrCreateObject( [ "apiPath" : self.apiPath ] )
            let streamItems = self.parseStreamItems( stream.items, context: context)
            persistentStream.addObjects( streamItems, to: "streamItems" )
            context.saveChanges()
            completion()
        }
        
        completion()
    }
}
