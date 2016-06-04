//
//  VDependencyManager+ForumNetworkSource.swift
//  victorious
//
//  Created by Darvish Kamalia on 6/2/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

extension VDependencyManager {
    var forumNetworkSource: ForumNetworkSource? {
        return singletonObjectOfType(NSObject.self, forKey: "networkLayerSource") as? ForumNetworkSource
    }
}

