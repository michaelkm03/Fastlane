//
//  HashtagSaveOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 3/3/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

class HashtagSaveOperation: FetcherOperation {
    
    let hashtags: [Hashtag]
    
    required init( hashtags: [Hashtag] ) {
        self.hashtags = hashtags
    }
    
    override func main() {
        
        guard !hashtags.isEmpty else {
            return
        }
        
        // Populate our local hashtags cache based off the new data
        persistentStore.createBackgroundContext().v_performBlockAndWait { context in
            for hashtag in self.hashtags {
                let persistentHashtag: VHashtag = context.v_findOrCreateObject([ "tag" : hashtag.tag ])
                persistentHashtag.populate(fromSourceModel: hashtag)
            }
            context.v_save()
        }
    }
}
