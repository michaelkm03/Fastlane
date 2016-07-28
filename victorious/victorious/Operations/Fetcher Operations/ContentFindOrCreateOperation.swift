//
//  ContentFindOrCreateOperation.swift
//  victorious
//
//  Created by Sharif Ahmed on 7/25/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

class ContentFindOrCreateOperation: FetcherOperation {
    private let contentModel: ContentModel
    private let contentID: Content.ID
    
    init?(contentModel: ContentModel) {
        self.contentModel = contentModel
        guard let contentID = contentModel.id else {
            return nil
        }
        self.contentID = contentID
        super.init()
        if let content = contentModel as? VContent {
            results = [content]
        }
    }
    
    override func main() {
        guard results == nil else {
            return
        }
        persistentStore.createBackgroundContext().v_performBlockAndWait { context in
            let content: VContent = context.v_findOrCreateObject(["v_remoteID": self.contentID])
            if let sourceModel = self.contentModel as? Content {
                content.populate(fromSourceModel: sourceModel)
            }
            context.v_save()
            let objectID = content.objectID
            
            self.persistentStore.mainContext.v_performBlockAndWait() { context in
                self.results = [ context.objectWithID(objectID) ]
            }
        }
    }
}
