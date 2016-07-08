//
//  VDependencyManager+NetworkResources.swift
//  victorious
//
//  Created by Vincent Ho on 5/24/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

extension VDependencyManager {
    var networkResources: VDependencyManager? {
        return childDependencyForKey("networkResources")
    }
    
    /// This should only be called after calling networkResources
    /// e.g. dependencyManager.networkResources?.userFetchAPIPath
    var userFetchAPIPath: String? {
        return stringForKey("userInfoURL")
    }
}
