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
    
    private let persistentStore = PersistentStore()
    private let apiPath: String
    
    init?( apiPath: String, sequenceID: String? = nil, pageNumber: Int = 1, itemsPerPage: Int = 15) {
        self.apiPath = apiPath
        super.init( request: StreamRequest(apiPath: apiPath, sequenceID: sequenceID, pageNumber: pageNumber, itemsPerPage: itemsPerPage)! )
    }
    
    override init( request: StreamRequest ) {
        self.apiPath = request.apiPath
        super.init(request: request)
    }
    
    var nextPageOperation: StreamOperation?
    var previousPageOperation: StreamOperation?
    
    override func onComplete(response: StreamRequest.ResultType, completion:()->() ) {
        let stream = response.results
        let uniqueElements = [ "apiPath" : self.apiPath ]
        
        persistentStore.asyncFromBackground() { context in
            let persistentStream: VStream = context.findOrCreateObject( uniqueElements )
            persistentStream.populate( fromSourceModel: stream )
            context.saveChanges()
        }
        
        if let nextPageRequest = response.nextPage {
            self.nextPageOperation = StreamOperation( request: nextPageRequest )
        }
        if let previousPageRequest = response.previousPage {
            self.previousPageOperation = StreamOperation( request: previousPageRequest )
        }
    }
}
