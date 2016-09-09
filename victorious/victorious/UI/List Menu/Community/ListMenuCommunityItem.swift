//
//  ListMenuCommunityItem.swift
//  victorious
//
//  Created by Tian Lan on 4/21/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

struct ListMenuCommunityItem {
    let title: String
    let streamAPIPath: APIPath
    let trackingURLs: [String]
    
    init?(_ dependencyManager: VDependencyManager) {
        guard
            let title = dependencyManager.stringForKey("title"),
            let streamAPIPath = dependencyManager.apiPathForKey("streamURL"),
            let trackingURLs = dependencyManager.trackingURLsForKey("view") as? [String]
        else {
            return nil
        }
        self.title = title
        self.streamAPIPath = streamAPIPath
        self.trackingURLs = trackingURLs
    }
}
