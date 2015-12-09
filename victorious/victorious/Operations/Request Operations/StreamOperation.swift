//
//  StreamOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 12/4/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

final class StreamOperation: RequestOperation, PaginatedOperation {
    
    let request: StreamRequest
    private(set) var resultCount: Int?
    
    private let apiPath: String
    
    required init( request: StreamRequest ) {
        self.apiPath = request.apiPath
        self.request = request
    }
    
    convenience init( apiPath: String, sequenceID: Int64? = nil, pageNumber: Int = 1, itemsPerPage: Int = 15) {
        self.init( request: StreamRequest(apiPath: apiPath, sequenceID: sequenceID)! )
    }
    
    override func main() {
        executeRequest( request, onComplete: self.onComplete )
    }
    
    private func onComplete( stream: StreamRequest.ResultType, completion:()->() ) {
        self.resultCount = stream.items.count
        
       persistentStore.asyncFromBackground() { context in
            let persistentStream: VStream = context.findOrCreateObject( [ "apiPath" : self.apiPath ] )
            let streamItems = VStreamItem.parseStreamItems(stream.items, context: context)
            persistentStream.addObjects( streamItems, to: "streamItems" )
            context.saveChanges()
            completion()
        }
    }
}
