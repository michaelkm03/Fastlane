//
//  ListMenuCommunityItem.swift
//  victorious
//
//  Created by Tian Lan on 4/21/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

/// A struct that wraps left menu items from the template

/// properties:
///     title - title of the stream (navigation bar title)
///     name - type of stream, eg: main.stream
///     streamAPIPath - API path for the stream
///     trackingURLs - array of urls used for tracking calls

struct ListMenuCommunityItem {
    let title: String
    let name: String
    let streamAPIPath: APIPath
    let trackingURLs: [String]
    
    init?(_ dependencyManager: VDependencyManager) {
        guard
            let title = dependencyManager.stringForKey("title"),
            let name = dependencyManager.stringForKey("name"),
            let streamAPIPath = dependencyManager.apiPathForKey("streamURL"),
            let trackingURLs = dependencyManager.trackingURLsForKey("view") as? [String]
        else {
            return nil
        }
        self.title = title
        self.name = name
        self.streamAPIPath = streamAPIPath
        self.trackingURLs = trackingURLs
    }
}
