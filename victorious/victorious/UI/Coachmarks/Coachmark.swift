//
//  Coachmark.swift
//  victorious
//
//  Created by Darvish Kamalia on 7/15/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

class Coachmark {
    let screenIdentifier: String
    let highlightIdentifier: String?
    let remoteID: String
    let dependencyManager: VDependencyManager
    var hasBeenShown = false
    var context: String?
    
    init(dependencyManager: VDependencyManager) {
        self.dependencyManager = dependencyManager
        self.screenIdentifier = dependencyManager.screenIdentifier ?? ""
        self.highlightIdentifier = dependencyManager.highlightIdentifier
        self.remoteID = dependencyManager.remoteID ?? ""
        self.context = dependencyManager.context
    }
}

private extension VDependencyManager {
    var screenIdentifier: String? {
        return stringForKey("screen")
    }
    
    var highlightIdentifier: String? {
        return stringForKey("highlight.target")
    }
    
    var remoteID: String? {
        return stringForKey("id")
    }
    
    var context: String? {
        return stringForKey("context")
    }
}
