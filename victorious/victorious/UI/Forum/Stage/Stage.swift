//
//  Stage.swift
//  victorious
//
//  Created by Sharif Ahmed on 3/8/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

protocol Stage: class, ForumEventReceiver {
    
    weak var delegate: StageDelegate? { get set }
    
    var dependencyManager: VDependencyManager! { get set }
    
    /// Replaces the currently content on the stage with the new one.
    func addContent(stageContent: StageContent)
    
    /// Removes the current content on the stage.
    func removeContent()
}

/// Conformers will recieve messages related to the stage resizing.
protocol StageDelegate: class {
    func stage(stage: Stage, didUpdateContentHeight size: CGFloat)
}
