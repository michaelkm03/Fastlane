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
    let name: String
    let streamAPIPath: APIPath
    
    init?(_ dependencyDictionary: [String: AnyObject]) {
        guard
            let title = dependencyDictionary["title"] as? String,
            let name = dependencyDictionary["name"] as? String,
            let streamURL = dependencyDictionary["streamURL"] as? String
        else {
                return nil
        }
        self.title = title
        self.name = name
        self.streamAPIPath = APIPath(templatePath: streamURL)
    }
}
