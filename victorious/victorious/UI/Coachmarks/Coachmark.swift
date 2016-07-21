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
        self.screenIdentifier = dependencyManager.stringForKey("screen")
        self.highlightIdentifier = dependencyManager.stringForKey("highlight.target")
        self.remoteID = dependencyManager.stringForKey("id")
        self.context = dependencyManager.stringForKey("context") 
    }
}