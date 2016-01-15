//
//  HashtagSearchOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 1/6/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

@objc class HashtagSearchResultObject: NSObject {
    let sourceResult: VictoriousIOSSDK.Hashtag
    
    init( hashtag: VictoriousIOSSDK.Hashtag ) {
        self.sourceResult = hashtag
    }
}

final class HashtagSearchOperation: RequestOperation, PaginatedOperation {
    
    private(set) var results: [AnyObject]?
    private(set) var didResetResults = false
    
    let request: HashtagSearchRequest
    private let escapedQueryString: String
    
    required init( request: HashtagSearchRequest ) {
        self.request = request
        self.escapedQueryString = request.searchTerm
    }
    
    convenience init?( searchTerm: String ) {
        guard let request = HashtagSearchRequest(searchTerm: searchTerm) else {
            return nil
        }
        self.init(request: request)
    }
    
    override func main() {
        requestExecutor.executeRequest(self.request, onComplete: self.onComplete, onError: self.onError)
    }
    
    private func onError( error: NSError, completion: ()->() ) {
        completion()
    }
    
    private func onComplete( networkResult: HashtagSearchRequest.ResultType, completion: () -> () ) {
        
        self.results = networkResult.map{ HashtagSearchResultObject(hashtag: $0) }
        
        // Queue parsing of network results into persistent store to execute after this operation completes
        // This allows calling code to receive the `resutls` above without having to wait
        // until all the hashtags are parsed and saved to the persistent store
        SaveHashtagsOperation(hashtags: networkResult).queueAfter(self)
        
        completion()
    }
}

class SaveHashtagsOperation: Operation {
    
    let hashtags: [Hashtag]
    
    var persistentStore: PersistentStoreType = PersistentStoreSelector.defaultPersistentStore
    
    required init( hashtags: [Hashtag] ) {
        self.hashtags = hashtags
    }
    
    override func start() {
        super.start()
        
        guard !hashtags.isEmpty else {
            self.finishedExecuting()
            return
        }
        
        self.beganExecuting()
        
        // Populate our local hashtags cache based off the new data
        persistentStore.createBackgroundContext().v_performBlockAndWait { context in
            
            for hashtag in self.hashtags {
                let persistentHashtag: VHashtag = context.v_findOrCreateObject([ "tag" : hashtag.tag ])
                persistentHashtag.populate(fromSourceModel: hashtag)
            }
            
            context.v_save()
            self.finishedExecuting()
        }
    }
}
